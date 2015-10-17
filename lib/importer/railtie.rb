
module Importer
  require 'rails'
     
  class Railtie < ::Rails::Railtie 
    initializer "importer.hook_up" do
      Importer::HookUp.init
    end   
  end

end