# -*- encoding: utf-8 -*-
require File.expand_path('../lib/gmail/version', __FILE__)

Gem::Specification.new do |gem|
  gem.authors       = ['Justin Perkins', 'Mikkel Malmberg', 'Frederico Galassi', 'Julien Blanchard']
  gem.email         = ['']
  gem.description   = %q{Write a gem description}
  gem.summary       = %q{Write a gem summary}
  gem.homepage      = ''

  gem.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  gem.files         = `git ls-files`.split("\n")
  gem.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  gem.name          = 'ruby-gmail'
  gem.require_paths = ['lib']
  gem.version       = Gmail::VERSION

  gem.add_development_dependency 'rake'
  gem.add_development_dependency 'mail'
  gem.add_development_dependency 'rspec'
  gem.add_development_dependency 'rspec-mocks'
end
