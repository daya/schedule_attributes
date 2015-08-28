# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "schedule_attributes/version"

Gem::Specification.new do |s|
  s.name        = "dgp-schedule_attributes"
  s.version     = ScheduleAttributes::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["David Gil", "Andrew Vit", "Mike Nicholaides"]
  s.email       = ["dgilperez@gmail.com", "andrew@avit.ca", "mike@ablegray.com"]
  s.homepage    = "https://github.com/dgilperez/schedule_attributes"
  s.summary     = %q{Handle form inputs for IceCube schedules}
  s.description = %q{Converts to/from date & time inputs for managing scheduled models.}

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_dependency 'ice_cube', '~> 0.13'
  s.add_dependency 'activesupport', '>= 3.2'
  s.add_dependency 'tzinfo' # this should be an activesupport dependency!

  # s.add_runtime_dependency 'railties', '>= 3.2'

  s.add_development_dependency 'rake'
  s.add_development_dependency 'rspec', '~> 2.99'
  s.add_development_dependency 'pry'
  s.add_development_dependency 'activerecord', '>= 3.2'
  s.add_development_dependency 'sqlite3'
  s.add_development_dependency 'appraisal'
end
