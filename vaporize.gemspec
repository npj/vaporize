# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)

Gem::Specification.new do |s|
  s.name        = "vaporize"
  s.version     = "0.0.1"
  s.platform    = Gem::Platform::RUBY
  s.authors     = [ "Peter Brindisi" ]
  s.email       = [ 'peter.brindisi@gmail.com' ]
  s.license     = 'MIT'
  s.homepage    = ''
  s.summary     = %q{ }
  s.description = %q{ }

  s.rubyforge_project = "vaporize"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.require_paths = [ "lib" ]
  
  s.add_dependency("aws-s3",  [ "~> 0.6.2"  ])
  s.add_dependency('sqlite3', [ "~> 1.3.5"  ])
  s.add_dependency('trollop', [ "~> 1.16.2" ])
end
