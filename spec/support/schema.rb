ActiveRecord::Schema.define do
  self.verbose = false

  create_table :profiles, :force => true do |t|
    t.string :name
    t.integer :age
    t.boolean :enabled
    t.timestamps
  end

end