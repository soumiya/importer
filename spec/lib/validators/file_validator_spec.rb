require 'spec_helper'

describe Importer::Validators::FileValidator do
    
  let(:file_object) { double("file", content_type: 'text/csv') }
  let(:file_validator) { Importer::Validators::FileValidator.new({attributes: 'import_file', content_type: 'text/csv'}) }
  let(:model_object) { double("model", errors: []) }
   
  it "validates only if attribute has a value" do
    file_validator.should_receive(:validate_content_type).never
    file_validator.validate_each(model_object, 'import_file', nil ) 
  end
  
  it "raises argument error on missing content_type and disallow options" do
    file_validator.stub(:options).and_return({})
    expect { file_validator.validate_each(model_object, 'import_file', file_object ) }.to raise_error(ArgumentError)
  end
  
  it "validates valid content_type" do
    model_object.errors.should_receive(:add).never
    file_validator.validate_each(model_object, 'import_file', file_object)
  end
  
  it "invalidate forbidden content_type with content_type option" do
    invalid_file_object = double("file", content_type: 'text/script')
    model_object.errors.should_receive(:add)
    file_validator.validate_each(model_object, 'import_file',  invalid_file_object)
  end
  
  it "invalidate forbidden content_type with disallow option" do
    disallow_file_validator = Importer::Validators::FileValidator.new({attributes: 'import_file', disallow: 'text/script'})
    invalid_file_object = double("file", content_type: 'text/script')
    model_object.errors.should_receive(:add)
    disallow_file_validator.validate_each(model_object, 'import_file',  invalid_file_object)
  end
  
  it "builds disallowed types from options" do
    disallow_file_validator = Importer::Validators::FileValidator.new({attributes: 'import_file', disallow: 'text/script'})
    expect(disallow_file_validator.disallowed_types).to eq(['text/script']) 
  end 
  
  it "builds allowed types from options" do
    allowed_file_validator = Importer::Validators::FileValidator.new({attributes: 'import_file', content_type: ['text/html','application/pdf']})
    expect(allowed_file_validator.allowed_types).to eq(['text/html','application/pdf']) 
  end   
  
  it "validates any file type except disallowed option" do
    disallow_file_validator = Importer::Validators::FileValidator.new({attributes: 'import_file', disallow: 'text/script'})
    model_object.errors.should_receive(:add).never
    disallow_file_validator.validate_each(model_object, 'import_file', file_object)   
  end  
  
end  