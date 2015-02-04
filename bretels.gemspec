# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require 'bretels/version'
require 'date'

Gem::Specification.new do |s|
  s.name     = 'bretels'
  s.version  = Bretels::VERSION
  s.date     = Date.today.strftime('%Y-%m-%d')
  s.authors  = ['brightin', 'thoughtbot']
  s.email    = 'developers@brightin.com'
  s.homepage = 'http://github.com/brightin/bretels'

  s.summary     = "Generate a Rails app using brightins's best practices."
  s.description = <<-HERE
Fork of thoughtbot's Suspenders for use at Brightin.
  HERE

  s.files = `git ls-files`.split("\n").
    reject { |file| file =~ /^\./ }.
    reject { |file| file =~ /^(rdoc|pkg)/ }
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.rdoc_options = ["--charset=UTF-8"]
  s.extra_rdoc_files = %w[README.md LICENSE]

  s.add_dependency 'rails', '~> 4.2.0'
  s.add_dependency 'bundler', '>= 1.1'
end
