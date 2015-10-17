require 'rubygems' 
require 'bundler/setup'

require 'pry'
require 'active_record'
require 'mongoid'
require 'database_cleaner'


require 'importer'


ActiveRecord::Base.establish_connection adapter: "sqlite3", database: ":memory:"
load "#{File.dirname(__FILE__)}/support/schema.rb"

Mongoid.configure do |config|
  config.connect_to("importer_test")
end

require 'support/active_record_models'
require 'support/mongoid_models'

RSpec.configure do |config|
  
  config.mock_with :rspec
  
  config.before(:suite) do
    DatabaseCleaner[:active_record].strategy = :transaction
    DatabaseCleaner[:mongoid].strategy = :truncation
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end
end