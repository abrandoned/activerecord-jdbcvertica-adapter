require 'rubygems'
require 'bundler'
Bundler.require(:default, :development, :test)

require 'minitest/mock'
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/pride'

require 'mocha/api'

config = YAML.load_file(File.dirname(File.expand_path(__FILE__)) + "/test_connection.yml")

ActiveRecord::Base.establish_connection(
  config['development']
)
