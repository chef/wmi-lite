# $:.unshift File.expand_path('../../lib', __FILE__)
require 'rspec'
require 'wmi-lite'

RSpec.configure do |config|
  config.include(RSpec::Matchers)
  config.treat_symbols_as_metadata_keys_with_true_values = true
  config.filter_run :focus => true
  config.filter_run_excluding :windows_only => true if ! (RUBY_PLATFORM =~ /mswin|mingw32|windows/)
  config.run_all_when_everything_filtered = true
end

