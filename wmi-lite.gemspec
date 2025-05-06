lib = File.expand_path("lib", __dir__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require "wmi-lite/version"

Gem::Specification.new do |spec|
  spec.name          = "wmi-lite"
  spec.version       = WmiLite::VERSION
  spec.authors       = ["Adam Edwards"]
  spec.email         = ["dev@chef.io"]
  spec.description   = "A lightweight utility over win32ole for accessing basic " \
                       "WMI (Windows Management Instrumentation) functionality " \
                       "in the Microsoft Windows operating system. It has no " \
                       "runtime dependencies other than Ruby, so it can be used " \
                       "without concerns around dependency issues."
  spec.summary       = "A lightweight utility library for accessing basic WMI " \
                       "(Windows Management Instrumentation) functionality on Windows"
  spec.homepage      = "https://github.com/chef/wmi-lite"
  spec.license       = "Apache-2.0"

  spec.files         = %w{LICENSE} + Dir.glob("lib/**/*")
  spec.require_paths = ["lib"]

  spec.required_ruby_version = "~> 3.1" # rubocop:disable Style/GuardClause

  spec.add_development_dependency "cookstyle", "~> 8.1"
end
