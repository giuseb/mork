# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "mork/version"

Gem::Specification.new do |s|
  s.name        = "mork"
  s.version     = Mork::VERSION
  s.licenses    = ['MIT']
  s.authors     = ["Giuseppe Bertini"]
  s.email       = ["giuseppe.bertini@gmail.com"]
  s.homepage    = 'https://github.com/giuseb/mork'
  s.summary     = %q{Optical mark recognition of multiple-choice tests and surveys}
  s.description = %q{Producing response sheets as PDF files and automatically scoring manually filled-out sheets}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {spec}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  # dependencies:
  s.add_dependency 'narray',    '~> 0.6'
  s.add_dependency 'rmagick',   '~> 2.13'
  s.add_dependency 'prawn',     '1.0.0.rc2'
  s.add_development_dependency 'rake',          '~> 10.3'
  s.add_development_dependency 'rspec',         '~>  3.1'
  s.add_development_dependency 'guard',         '~>  2.6'
  s.add_development_dependency 'guard-rspec',   '~>  4.3'
  s.add_development_dependency 'guard-shell',   '~>  0.6'
  # s.add_development_dependency 'rb-fsevent'
  s.add_development_dependency 'awesome_print', '~>  1.2'
end