module Importer
  
  class << self
    attr_accessor :configuration
     
    def configuration
      @configuration ||= Configuration.new
    end 
    
    def configure
      yield(configuration) if block_given?
      configuration
    end
     
  end
  
  class Configuration
    attr_accessor :parser_options, :log
    
    def initialize
      @parser_options = {:col_sep => ","}
      @log = false
    end
    
    def log?
      @log || false
    end   
    
  end
   
end  