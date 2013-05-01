$: << File.join(File.dirname(__FILE__), "../src")
require 'rspec'

RSpec.configure do |config|
  config.mock_framework = :rspec
end