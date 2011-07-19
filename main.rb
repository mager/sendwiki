require 'rubygems'
require 'sinatra'
require 'mongo_mapper'
require 'sendgrid'
require './model'

get '/' do
  erb :main
end
