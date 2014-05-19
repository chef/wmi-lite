# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'wmi-lite/version'

Gem::Specification.new do |spec|
  spec.name          = 'wmi-lite'
  spec.version       = WmiLite::VERSION
  spec.authors       = ['Adam Edwards']
  spec.email         = ['dev@getchef.com']
  spec.description   = 'A lightweight utility over win32ole for accessing basic ' \
                       'WMI (Windows Management Instrumentation) functionality ' \
                       'in the Microsoft Windows operating system. It has no '  \
                       'runtime dependencies other than Ruby, so it can be used ' \
                       'without concerns around dependency issues.'
  spec.summary       = 'A lightweight utility library for accessing basic WMI '     \
                       '(Windows Management Instrumentation) functionality on Windows'
  spec.homepage      = 'https://github.com/opscode/wmi-lite'
  spec.license       = 'Apache 2.0'

  spec.files         = `git ls-files`.split($/)
  spec.executables   = spec.files.grep(%r{^bin/}) { |f| File.basename(f) }
  spec.test_files    = spec.files.grep(%r{^(test|spec|features)/})
  spec.require_paths = ['lib']

  spec.add_development_dependency 'bundler', '~> 1.3'
  spec.add_development_dependency 'rspec'
  spec.add_development_dependency 'rake'
  spec.add_development_dependency 'pry'
  spec.add_development_dependency 'pry-debugger'
end
