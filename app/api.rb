# Gemfile libraries
require 'sinatra'

# Internal operations libraries
require './oulipean/api'
include Oulipean


# Process calls to valid Oulipean endpoints
post '/oulipean/:op?' do
  operation = request.path_info.split('/', 3).last
  Oulipean.send(operation)
end
