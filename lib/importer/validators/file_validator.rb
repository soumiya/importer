module Importer
  
  module Validators
    class FileValidator < ActiveModel::EachValidator

      def validate_each(record, attribute, value)
        return unless value.present? && value.try(:content_type)
        validate_content_type(record, attribute, value.send(:content_type))
      end

      def validate_content_type(record, attribute, content_type)
        unless options.has_key?(:content_type) || options.has_key?(:disallow)
          raise ArgumentError, 'set :content_type or :disallow'
        end
  
        if allowed_types.present? && allowed_types.none? { |atype| atype.casecmp(content_type) == 0}
          record.errors.add(attribute,"is not a allowed file-type.")
        end 
  
        if disallowed_types.present? && disallowed_types.any? { |dtype| dtype.casecmp(content_type) == 0}
          record.errors.add(attribute,'is not a allowed file-type.')
        end 
      end

      def allowed_types
        [options[:content_type]].flatten.compact
      end

      def disallowed_types
        [options[:disallow]].flatten.compact
      end 

    end 
 end 
  
end  
