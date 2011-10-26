require 'rspec'
require 'simplecov'
require File.expand_path('../../lib/net/nntp', __FILE__)

Dir[File.expand_path('../support/**/*.rb', __FILE__)].each { |f| require f }

RSpec.configure do |config|
end
