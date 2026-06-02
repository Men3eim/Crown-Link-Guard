ENV['RAILS_ENV'] ||= 'test'
require_relative '../config/environment'
require 'rails/test_help'

class ActiveSupport::TestCase
  parallelize(workers: 1)

  # Add more helper methods to be used by all tests here...
end
