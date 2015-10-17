module Importer
  module ActiveRecordImporter
      
    def self.included(base)
      base.send(:extend, Importer::KlassMethods)
      base.send(:extend, KlassMethods) 
      base.send(:include, InstanceMethods)   
    end
       
    module KlassMethods 
      
      def process_csv_row(data, action)
        case action
        when /^add/i
          data.delete(:id)
          klass_instance=self.new
          build_csv_object(klass_instance, data) if klass_instance
        when /^update/i
          klass_instance=self.find(data[:id])
          build_csv_object(klass_instance, data) if klass_instance      
        when /^destroy/i 
          klass_instance=self.find(data[:id])  
        end  
        klass_instance   
      rescue ActiveRecord::RecordNotFound => e
         raise Importer::RecordNotFound, "Record Not Found for #{action}", caller
      end
      
      def build_csv_object(klass_instance=nil, data=nil)
        return unless klass_instance && data
        cols_hash = self.columns_hash
        data.each_pair do |key, value|
          value = false if cols_hash[key.to_s].try(:type) == :boolean && value.nil?
          begin
            klass_instance.send("#{key}=", value)
          rescue ActiveRecord::RecordNotFound => e
            raise Importer::RecordNotFound, "Record Not Found for #{key} with value #{value}", caller
          rescue NoMethodError => exception
            raise Importer::MissingKey, "Could not find your key \"#{key}\""
          end
        end  
      end  
  
    end 
    module InstanceMethods
      def import_validation_message(msg)
        #customize if required
        msg
      end  
            
    end  
       
  end
end  
