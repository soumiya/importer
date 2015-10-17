require 'spec_helper'


describe Importer::Csv do
  
  before(:each) { Profile.new_import }
  
  let!(:smarter_csv_resultset) do 
    [
       {id: nil, name: 'ben', action: 'add'},
       {id: nil, name: 'sen', action: 'add'},
       {id: 123, name: 'len',  action: nil }
     ]
  end 
  
  let!(:existing_profile) { Profile.create({name: 'ken'})} 
  let!(:data_file) {  double("data_file", content_type: 'text/csv', path: '/path_to_file') }
  let!(:importer_csv) { Importer::Csv.new { |c| c.import_file = data_file } }
  
  it "validates presence of attribute import_file" do
    nofile_importer_csv = Importer::Csv.new
    expect(nofile_importer_csv.valid?).not_to be_true
    expect(nofile_importer_csv.errors[:import_file]).to include("can't be blank")
  end

  it "expects csv contenttype" do
    expect(importer_csv.valid?).to be_true
  end

  it "invalidates bad content-type" do
    data_file.stub(:content_type).and_return('text/script')
    expect(importer_csv.invalid?).to be_true
  end

  it "run_parser returns indexed hash of import_klass objects" do
    Smarter::Parser.any_instance.stub(:read_and_process).and_return(smarter_csv_resultset)
    importer_csv.stub(:klass).and_return(Profile)
    resultset = importer_csv.run_parser
    expect(resultset.is_a?(Array)).to be_true
  end


  it "run_parser ignores records with all actions except [add, update]" do
    smarter_csv_resultset[0][:action] = "insert"
    smarter_csv_resultset[1][:action] = "new"
    smarter_csv_resultset[2][:action] = "delete"
    Smarter::Parser.any_instance.stub(:read_and_process).and_return(smarter_csv_resultset)
    importer_csv.import_klass_name = Profile.name
    expect {
      importer_csv.save
    }.to change{ Profile.count }.by(0)
  end

  it "processing of cvs row data is delegated to import_klass" do
    Smarter::Parser.any_instance.stub(:read_and_process).and_return(smarter_csv_resultset)
    expect(Profile).to receive(:process_csv_row).at_least(:once)
    importer_csv.stub(:klass).and_return(Profile)
    resultset = importer_csv.run_parser
  end

  it "creates new import_klass records for each csv row with action 'add' " do
    Smarter::Parser.any_instance.stub(:read_and_process).and_return(smarter_csv_resultset)
    importer_csv.import_klass_name = Profile.name
    expect {
      importer_csv.save
    }.to change{ Profile.count }.by(2)

  end

  it "updates existing import_klass  records for each csv row with action 'update' " do
    smarter_csv_resultset[0][:id] = existing_profile.id
    smarter_csv_resultset[0][:action]= "update"
    importer_csv.import_klass_name = Profile.name
    Smarter::Parser.any_instance.stub(:read_and_process).and_return(smarter_csv_resultset)
    expect {
      importer_csv.save
    }.to change{ Profile.find(existing_profile.id).name }.from('ken').to('ben')
  end

  it "load_imported_data raises error on 'update' action for missing records" do
    smarter_csv_resultset[0][:id] = 123
    smarter_csv_resultset[0][:action]= "update"
    importer_csv.import_klass_name = Profile.name
    Smarter::Parser.any_instance.stub(:read_and_process).and_return(smarter_csv_resultset)
    expect {
      importer_csv.load_imported_data
    }.to raise_error
  end

  it "does not import datalist with errors" do
    importer_csv.import_klass_name = Profile.name
    Smarter::Parser.any_instance.stub(:read_and_process).and_return(smarter_csv_resultset)
    importer_csv.stub(:imported_list_is_error_free?).and_return(false)
    expect(importer_csv.save).not_to be_true
  end

  it "does not import empty or bad file" do
    importer_csv.import_klass_name = Profile.name
    importer_csv.import_file = nil
    expect(importer_csv.save).not_to be_true
    expect(importer_csv.errors[:import_file]).not_to be_empty
  end

  it "does not import empty datalist" do
    importer_csv.import_klass_name = Profile.name
    Smarter::Parser.any_instance.stub(:read_and_process).and_return([])
    expect(importer_csv.save).not_to be_true
    expect(importer_csv.errors[:import_file].first).to match(/has nothing to import please provide actions/)
  end

  it "does not save with RecordNotFound error" do
    importer_csv.import_klass_name = Profile.name
    Smarter::Parser.any_instance.stub(:read_and_process).and_return([{id: "", name: 'len',  action: 'update' }])
    expect(importer_csv.save).not_to be_true
    expect(importer_csv.errors[:base]).to include("Row 2: record not found for update")
  end

  it "saves all or none of the records" do
    profile1 = Profile.create(name: 'profile1')
    profile2 = Profile.create(name: 'profile2')
    importer_csv.import_klass_name = Profile.name
    Smarter::Parser.any_instance.stub(:read_and_process).and_return([{id: profile1.id, name: 'len',  action: 'update' }, {id: profile2.id, name: 'len',  action: 'destroy'}])
    Profile.any_instance.stub(:destroy).and_return(false)
    expect(importer_csv.save).not_to be_true
    profile1.reload
    expect(profile1.name).to eq('profile1')
  end    
   
  it "does not execute ignored_actions" do
    Smarter::Parser.any_instance.stub(:read_and_process).and_return(smarter_csv_resultset)
    importer_csv_with_options = Importer::Csv.new do |c|
      c.import_file = data_file; c.import_options = {ignore_actions: [:add]} ; c.import_klass_name = Profile.name;
    end
    expect(importer_csv_with_options.save).not_to be_true
    expect(importer_csv_with_options.errors[:base]).to include("Row 2: action \"add\" is not allowed", "Row 3: action \"add\" is not allowed")
  end
 
end  

