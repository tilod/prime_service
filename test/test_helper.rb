require 'minitest/autorun'
require 'minitest/reporters'

require 'prime_service'
require 'pry'

Minitest::Reporters.use! Minitest::Reporters::DefaultReporter.new(color: true)
