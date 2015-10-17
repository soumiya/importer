module Smarter
  require 'csv'
  class HeaderSizeMismatch < Exception; end

  class IncorrectOption < Exception; end

  class Parser
    attr_accessor :file_path, :options, :convert_values_to_numeric, :keys, :csv_array_set, :processed_csv


    def initialize(file_path, options = {})
      @file_path                 = file_path
      @convert_values_to_numeric = options.delete(:convert_values_to_numeric) || false
      @keys                      = []
      @ignore_keys               = options.delete(:ignore_keys) || []
      @options                   = options || nil
    end

    def read_and_process
      read
      process
    end

    def read
      @csv_array_set = init_csv
    end

    def process
      build_keys
      @processed_csv = []
      @csv_array_set.each do |values|
        row_hash = {}
        @keys.each_with_index do |key, index|
          next if @ignore_keys.include?(key)
          row_hash[key] = process_format(values[index])
        end
        @processed_csv << row_hash
      end
      @processed_csv
    end

    private

    def process_format(value)
      return value unless @convert_values_to_numeric
      # convert if it's a numeric value:
      case value
      when /^[+-]?\d+\.\d+$/
        value.to_f
      when /^[+-]?\d+$/
        value.to_i
      else
        value
      end
    end

    def build_keys
      return if @csv_array_set.empty?
      return unless @keys.empty? # return if @keys.present?
      keys = @csv_array_set[0]
      return unless keys.present?
      @keys = keys.compact.reject(&:blank?).map(&:to_sym)
      @csv_array_set.delete_at(0) if @keys.present?
    end

    def init_csv
      content           = File.read(@file_path)
      detection         = CharlockHolmes::EncodingDetector.detect(content)
      utf8_content      = CharlockHolmes::Converter.convert content, detection[:encoding], 'UTF-8'
      csv               = CSV.new(utf8_content, @options)
      csv.present? ? csv.to_a : []
    end

  end
end
