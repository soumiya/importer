module Importer  
  
  class HookUp
    def self.init
      if defined?(ActiveRecord)
        ActiveSupport.on_load(:active_record) do
          ActiveRecord::Base.send :include, Importer::ActiveRecordImporter
        end
      end  
      
      begin; require 'mongoid'; rescue LoadError; end
      if defined? ::Mongoid
        ::Mongoid::Document.send :include, Importer::MongoidImporter
      end
    end    
  end 
     
end  