# -*- encoding: utf-8 -*-
$:.push File.expand_path('../lib', __FILE__)
require 'net/nntp/version'

Gem::Specification.new do |s|
  s.name        = 'net-nntp'
  s.version     = Net::NTTP::VERSION
  s.authors     = ['James Conroy-Finn']
  s.email       = ['james@logi.cl']
  s.homepage    = 'https://github.com/jcf/net-nttp'
  s.summary     = %q{Net::NTTP}
  s.description = %q{Net::NTTP}

  # s.rubyforge_project = 'broadcast'

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ['lib']
end
