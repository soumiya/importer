require 'spec_helper'

describe Importer::Configuration do
  
  it "has parser option" do
    expect(Importer::Configuration.new.respond_to?(:parser_options)).to be_true
  end
  
  it "has log option" do
    expect(Importer::Configuration.new.respond_to?(:log)).to be_true
  end
  
  it "configuration options are set" do
    Importer.configure { |c| c.parser_options = {col_sep: ";"} ; c.log = true}
    expect(Importer.configuration.parser_options[:col_sep]).to eq(';') 
    expect(Importer.configuration.log?).to be_true   
  end  
  
    
end  