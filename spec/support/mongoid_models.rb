require 'mongoid'

class Contact
  include Mongoid::Document
  include Importer
  
  field :name, type: String
  field :phone, type: String
  
  validates :name, presence: true, uniqueness: true
end
