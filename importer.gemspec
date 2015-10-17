# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'importer/version'

Gem::Specification.new do |spec|
  spec.name          = "importer"
  spec.version       = Importer::VERSION
  spec.authors       = ["sowmya"]
  spec.email         = ["sowmya.gopinath@RACKSPACE.COM"]
  spec.homepage      = "https://github.rackspace.com/GSCS/importer"
  spec.description   = %q{ This uses SmartCSV to import the data. This also will extend you models and much of your code. }
  spec.summary       = %q{imports data from csv}
  spec.license       = "MIT"

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ["lib"]

  spec.add_development_dependency "bundler", "~> 1.3"
  spec.add_development_dependency "rake"
  spec.add_development_dependency 'activerecord', '> 4.0.0'
  spec.add_development_dependency "mongoid", "~> 4.0.2"
  spec.add_development_dependency 'rspec', '~> 2.14.1'
  spec.add_development_dependency 'database_cleaner'
  spec.add_development_dependency 'sqlite3'
  spec.add_development_dependency 'pry', '~> 0.9.12.6'
  spec.add_runtime_dependency 'airbrake'
  spec.add_runtime_dependency 'activemodel', '> 4.0.0'
  spec.add_runtime_dependency 'charlock_holmes'  , '0.7.3'
end
