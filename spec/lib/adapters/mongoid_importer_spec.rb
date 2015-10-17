require 'spec_helper'

describe Importer::MongoidImporter do
  
  it "included to Mongoid Class" do
    expect(Contact.included_modules).to include(Importer::MongoidImporter)
  end  
  
  it "new_importer instantiates importer_csv object" do
    expect(Contact.new_import.is_a?(Importer::Csv)).to be_true
  end 
  
  it "handles processing of cvs row data to import_klass objects" do
    expect(Contact.respond_to?(:process_csv_row)).to be_true
  end
  
  it "process_csv_row row raises Mongoid Error on record not found for update" do
    expect(Contact.where({_id: '67'}).first).to be_nil
    expect { Contact.process_csv_row({_id: '67', name: 'ben', action: 'update'})}.to raise_error
  end
  
  describe "import_validation_message" do
    it "acts like a placeholder for customizing validation messages" do
      expect(Contact.new.respond_to?(:import_validation_message)).to be_true
    end  
  end   
  
end  
  