require 'spec_helper'

describe Importer::ActiveRecordImporter do
  
  it "included to Active Record Class" do
    expect(Profile.included_modules).to include(Importer::ActiveRecordImporter)
  end 
  
  it "import_resource sets default import_options" do
    Profile.import_resource
    expect(Profile.import_options).to eq({readonly_fields: [], ignore_actions: [:destroy]})
  end   
  
  it "new_importer instantiates importer_csv object" do
    expect(Profile.new_import.is_a?(Importer::Csv)).to be_true
  end 
  
  it "handles processing of cvs row data to import_klass objects" do
    expect(Profile.respond_to?(:process_csv_row)).to be_true
  end
  
   
  it "boolean data with nil value is considered false" do
    processed_row = Profile.process_csv_row({'name' => 'ben', 'enabled' => nil}, 'add')
    expect(processed_row.enabled).to eq(false)
  end  
  
  describe "process_csv_row" do
    it 'should raise error when record not found' do
      expect{ Profile.process_csv_row({at: 'ben'}, 'add') }.to raise_error(Importer::MissingKey)
      
    end
    
    it "returns import_klass instance" do
      processed_row = Profile.process_csv_row({'name' => 'ben', 'enabled' => nil}, 'add')
      expect(processed_row.is_a?(Profile)).to be_true
    end  
    
    it "row raises ActiveRecord Error on record not found for update" do
      expect(Profile.where({id: 67}).first).to be_nil
      expect { Profile.process_csv_row({id: 67, name: 'ben'}, 'update')}.to raise_error(Importer::RecordNotFound)
    end 
  
  end
  
  describe "import_validation_message" do
    it "acts like a placeholder for customizing validation messages" do
      expect(Profile.new.respond_to?(:import_validation_message)).to be_true
    end  
  end  

  
end  
  