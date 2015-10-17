require "importer/version"
require "active_model"
require "smarter/parser"
require "importer/configuration"
require "importer/validators/file_validator"
require "importer/hook_up"
require "importer/adapters/active_record_importer"
require "importer/adapters/mongoid_importer"
require "importer/csv"
require "logger"



module Importer
  
  class Error < ::Exception; end
  class RecordNotFound < Error; end
  class MissingKey < Error; end
  class Rollback < Error; end
  
  module InstanceMethods
    attr_accessor :import_validate
  end  
   
  module KlassMethods
    
    def self.extended(base)
      base.class_attribute :import_options
    end 
    
    def default_import_options
      {readonly_fields: [], ignore_actions: [:destroy]}
    end   
    
    def import_resource(options={})
      self.import_options = default_import_options.merge(options)
    end  
    
    def new_import(file = nil, options = {})
      include Importer::InstanceMethods
      @imported_csv = Importer::Csv.new do |imported_csv|
        imported_csv.import_file = file
        imported_csv.import_klass_name = self.name
        imported_csv.import_options = self.import_options || self.default_import_options
        imported_csv.import_options.merge!(options)
        imported_csv.set_import_readonly_fields
        imported_csv.set_import_actions
      end
    end    
       
  end  
   
  def self.included(base)
    if base.respond_to?(:descends_from_active_record?) && base.descends_from_active_record?
      base.send(:include, Importer::ActiveRecordImporter)
    elsif defined?(Mongoid) && base.ancestors.include?(Mongoid::Document)
      base.send(:include, Importer::MongoidImporter)   
    else
      raise Error.new("Can't determine adapter for #{base.class} class.")
    end
  end

end

begin; require 'rails'; rescue LoadError; end
require 'importer/railtie' if defined?(Rails)