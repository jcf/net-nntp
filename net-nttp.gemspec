# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'net/nntp/version'

Gem::Specification.new do |s|
  s.name        = 'net-nntp'
  s.version     = Net::NNTP::VERSION
  s.authors     = ['James Conroy-Finn']
  s.email       = ['james@logi.cl']
  s.homepage    = 'https://github.com/jcf/net-nttp'
  s.summary     = %q{Net::NTTP}
  s.description = %q{Net::NTTP}

  # s.rubyforge_project = 'net-nntp'

  s.add_development_dependency 'rake', '>= 0.9'
  s.add_development_dependency 'rspec', '>= 2.7'
  s.add_development_dependency 'guard-rspec', '>= 0.5'
  s.add_development_dependency 'simplecov', '>= 0.5'
  s.add_development_dependency 'simplecov-gem-adapter', '>= 1'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
