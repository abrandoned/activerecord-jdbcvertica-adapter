require 'rubygems'
require 'bundler'
Bundler.require(:default, :development, :test)

require 'minitest/mock'
require 'minitest/spec'
require 'minitest/autorun'
require 'minitest/pride'

require 'mocha/api'

ActiveRecord::Base.establish_connection({"adapter"=>"vertica5", "encoding"=>"utf8", "host"=>"localhost", "port"=>5433, "username"=>"dbadmin", "database"=>"docker"})

