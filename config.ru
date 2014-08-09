require 'rubygems'

ENV['RACK_ENV'] ||= ENV['RAILS_ENV'] ||= 'development'

require 'bundler/setup'

Bundler.require(:default)

require './app/application'

run RadioApp
