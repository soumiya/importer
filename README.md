# Importer

Imports data in cvs format. Supports ActiveRecord and Mongoid adapter

## Installation

Add this line to your application's Gemfile:

    gem 'importer'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install importer

## Usage

#### optional configuration

```ruby
  Importer.configure do |c|
    c.parser_options = { :col_sep => "," }
  end
  
```

#### optional class methods
import_resource method takes options :readonly_fields, :ignore_actions

readonly_fields are fields only for display. Any changes to them are not persisted
ignore_actions restricts actions during import

```ruby
  class CategoryCombination < ActiveRecord::Base
    import_resource readonly_fields: [:item_name, :category_name_], ignore_actions: [:update]
  end
  
```
