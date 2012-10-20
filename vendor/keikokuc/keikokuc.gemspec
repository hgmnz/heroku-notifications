# -*- encoding: utf-8 -*-
require File.expand_path('../lib/keikokuc/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ["Harold Giménez"]
  gem.email         = ["harold.gimenez@gmail.com"]
  gem.description   = %q{Keikoku client}
  gem.summary       = %q{Keikoku is an experimental notification system on Heroku. This gem interfaces with the keikoku API to be used bynotification producers and consumers}
  gem.homepage      = "https://github.com/hgmnz/keikokuc"

  gem.files         = `git ls-files`.split($\)
  gem.executables   = gem.files.grep(%r{^bin/}).map{ |f| File.basename(f) }
  gem.test_files    = gem.files.grep(%r{^(test|spec|features)/})
  gem.name          = "keikokuc"
  gem.require_paths = ["lib"]
  gem.version       = Keikokuc::VERSION

  gem.add_dependency 'rest-client'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'sham_rack'
end
