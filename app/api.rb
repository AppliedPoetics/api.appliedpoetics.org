# Gemfile libraries
require 'sinatra'
require 'require_all'

# Internal operations libraries
require_all 'methods'
include Oulipean

# Process calls to valid endpoints; fence out
# all of the bad requests
post '/:category?/:operation?' do
  category = params[:category]
  operation = params[:operation]
  begin
    response = :category.public_send(operation, "HI")
    status 200
    JSON({
      res: response
    })
  rescue NoMethodError => e
    status 418
    JSON({
      res: "Bad method"
    })
  end
end
