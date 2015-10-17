module Importer
  class Csv
    include ActiveModel::Model
    include Validators
    include Smarter

    
    attr_reader :configuration, :logger
    attr_accessor :import_file, :import_klass_name, :import_options, :imported_data

    validates :import_file, presence: true, file: {content_type: ['text/csv','text/x-comma-separated-values','text/plain', 'text/comma-separated-values', 'application/x-comma-separated-values', 'application/x-comma-separated-values', 'application/csv', 'application/excel', 'application/vnd.ms-excel', 'application/vnd.msexcel'], disallow: 'text/script'}
    
    
    def initialize
      super
      @csv_file = []
      @klass_instance_actions = []
      @updated_records = []
      @created_records = []
      @destroyed_records = []
      @import_options = {}
      @configuration = Importer.configuration
      @logger = Logger.new(STDOUT)
      results = yield self if block_given?
    end
    
    def saved_records
      [@created_records, @updated_records].count
    end
    
    def total_saved_records
      @created_records.count + @updated_records.count
    end
    
    def destroyed_records
      @destroyed_records
    end 
    
    def total_destroyed_records
      @destroyed_records.count
    end  
    
    def total_invalid_records
      @klass_instance_actions.compact.reject do |klass_instance_action|
        action = klass_instance_action[:action]
        klass_instance = klass_instance_action[:processed_instance]     
        klass_instance.destroyed? || klass_instance.valid?
      end.count
    end
    
    def total_records_without_action
      total_records = @klass_instance_actions.count
      @csv_file.count - total_records
    end
    
    def partial_saved?
      @klass_instance_actions.count != (total_saved_records + total_destroyed_records)
    end
    
    def log message
      return unless configuration.log?
      @logger.debug message    
    end   
    
    def load_import_data
      return false unless self.valid?
      run_parser if self.import_klass_name
      imported_list_is_error_free?
    end
   
    def run_parser
      build_csv_file
      @klass_instance_actions.clear
      @csv_file.each_with_index do |record, index|  
        break unless identify_record(record, index) 
      end 
    end 
    
    def imported_list_is_error_free?    
      errors.add :import_file, "has nothing to import please provide actions" if @klass_instance_actions.empty?    
      @klass_instance_actions.each do |klass_instance_action|
        klass_instance = klass_instance_action[:processed_instance]
        action = klass_instance_action[:action]
        index = klass_instance_action[:index]   
        next if klass_instance.nil?
        next if klass_instance.destroyed? || klass_instance.valid?  
        klass_instance.errors.full_messages.each do |msg|
          errors.add :base, "Row #{index + 2}: #{klass_instance.import_validation_message(msg.downcase)}"
        end   
      end  
      errors.empty?
    end
    
    def save
      success = false
      return success unless load_import_data
      reset_records 
      if klass.respond_to?(:transaction)  
         klass.transaction(requires_new: true) { save_all_or_none! }
      else
         save_all_or_none!   
      end
      success = true
    rescue Importer::Rollback => e
      klass.respond_to?(:transaction) ? reset_records : cleanup_created_records 
      success = false
    ensure
      success
    end
      
    def import_readonly_fields
       @import_readonly_fields || set_import_readonly_fields
    end
    
    def import_actions
      @import_actions || set_import_actions
    end 
    
    def set_import_readonly_fields
      @import_readonly_fields = [import_options[:readonly_fields]].flatten.compact
    end  
    
    def set_import_actions
      @import_actions = [:add, :update, :destroy]-([import_options[:ignore_actions]].flatten.compact)
    end     
    
    private
    
    # It will clean up only the records that were added
    # called if transaction is not supported
    def cleanup_created_records
      @created_records.each(&:destroy)
      @created_records.clear
    end
    
    def itemize_imported_record(imported_record, action)
      return if imported_record.nil?
      case action
      when /^destroy/i
        @destroyed_records << imported_record
      when /^add/i
        @created_records << imported_record
      when /^update/i  
        @updated_records << imported_record    
      end  
    end  
       
    def save_all_or_none! 
      success = false  
      @klass_instance_actions.each do |record_action|   
        record = record_action[:processed_instance]
        action = record_action[:action]
        index  = record_action[:index]
        case action          
        when /^destroy/i
          success = record.destroy  
        when /^(add|update)/i  
          success = record.save            
        end 
        unless success 
          record.errors.full_messages.each do |msg|
            errors.add :base, "Row #{index + 2}: #{klass_instance.import_validation_message(msg.downcase)}"
          end         
          raise Importer::Rollback 
        end
        itemize_imported_record(record, action)              
      end
      success
    end
       
    def klass
      @klass ||= self.import_klass_name.constantize
    end
    
    def identify_record(record, index)
      action = record.delete(:action).to_s.strip 
      processed_instance = nil
      success = false
      if action.present?
       raise Importer::Error, "action \"#{action}\" is not allowed" unless self.import_actions.include?(action.downcase.to_sym) 
       processed_instance = klass.process_csv_row(record, action) 
       processed_instance.import_validate = true if processed_instance.respond_to?(:import_validate)
       @klass_instance_actions.push({processed_instance: processed_instance, action: action, index: index })
      end 
      success = true
    rescue Importer::MissingKey, Importer::RecordNotFound, Importer::Error => exception 
      errors.add :base, "Row #{index + 2}: #{exception.message.downcase}" 
    ensure
      success          
    end
    
    def build_csv_file
      return unless self.import_file.present?
      ignore_keys = self.import_readonly_fields
      csv_parser = Smarter::Parser.new(self.import_file.path, { ignore_keys: ignore_keys })
      @csv_file = csv_parser.read_and_process
    rescue CSV::MalformedCSVError => exception
      errors.add :import_file, "is malformed. #{exception.message}"
      Airbrake.notify(exception)
    end
    
    def reset_records
      @created_records.clear
      @updated_records.clear
      @destroyed_records.clear
    end  
    
  end
end  
