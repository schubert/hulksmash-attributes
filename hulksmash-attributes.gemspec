# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "hulksmash/attributes/version"

Gem::Specification.new do |s|
  s.name        = "hulksmash-attributes"
  s.version     = HulkSmash::Attributes::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Michael Schubert"]
  s.email       = ["michael@schubert.cx"]
  s.homepage    = "https://github.com/schubert/hulksmash-attributes"
  s.summary     = %q{Hulk angry at manually mapping attributes between systems. Hulk Smash!}
  s.description = %q{Smash attributes into the shape you need them and back again using Procs}

  s.rubyforge_project = "hulksmash-attributes"

  s.add_development_dependency('rspec-rails', '>= 2.5')
  s.add_development_dependency('activerecord')
  s.add_development_dependency('with_model')
  s.add_development_dependency('nokogiri')
  s.add_development_dependency('sqlite3')
  s.add_development_dependency('ruby-debug19')
  s.add_development_dependency('autotest')

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]
end
