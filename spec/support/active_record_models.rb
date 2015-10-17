require 'active_record'

class Profile < ActiveRecord::Base
  include Importer
  validates :name, presence: true, uniqueness: true
end