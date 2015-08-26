require 'active_support'
require 'ostruct'
require 'support/parser_macros'

# $: << File.expand_path('../lib')

RSpec.configure do |config|
  config.include SpecHelpers::ParserMacros
  config.expect_with :rspec

  config.before(:each) do
    IceCube.compatibility = 12 if defined?(IceCube)
  end
end
