# config.ru
require 'bundler'
Bundler.require

require './app'
run Sinatra::Application