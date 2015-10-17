require 'spec_helper'

describe Smarter::Parser do
  let!(:csv_rows) do 
    [ ['id','name','action'],['1','vixtor','add'], ['2','paul','add']]
  end 
  let!(:data_file) {  double("data_file", content_type: 'text/csv', path: '/path_to_file') }
  
  it "returns an array of data hash repesenting each row of csv file" do
    Smarter::Parser.any_instance.stub(:init_csv).and_return(csv_rows) 
    smarter_parser = Smarter::Parser.new(data_file)
    expect(smarter_parser.read_and_process).to eq([{:id=>"1", :name=>"vixtor", :action=>"add"}, {:id=>"2", :name=>"paul", :action=>"add"}])
  end 
  
  it "with option convert_values_to_numeric, all number strings are converted to number formats" do
    Smarter::Parser.any_instance.stub(:init_csv).and_return(csv_rows) 
    smarter_parser = Smarter::Parser.new(data_file, {convert_values_to_numeric: true})
    expect(smarter_parser.read_and_process).to eq([{:id=> 1, :name=>"vixtor", :action=>"add"}, {:id=> 2, :name=>"paul", :action=>"add"}])
  end 
  
  it "does not process ignored_keys" do
    Smarter::Parser.any_instance.stub(:init_csv).and_return(csv_rows) 
    smarter_parser = Smarter::Parser.new(data_file, {ignore_keys: [:name, :action]})
    expect(smarter_parser.read_and_process).to eq([{:id=>"1"}, {:id=>"2"}])
  end 
  
end  