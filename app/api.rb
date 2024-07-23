# Gemfile libraries
require 'sinatra'
require 'fileutils'
require 'securerandom'
require 'require_all'
require 'include_all'

# Internal operations libraries
require_all 'methods'
include_all

def write_resource(content)
  FileUtils.mkdir_p 'resources'
  name = SecureRandom.uuid
  begin
    File.open("resources/#{name}", "w") {
      |file| file.write(content)
    }
  rescue => e
    false
  end
  true
end

# Process calls to valid endpoints; fence out
# all of the bad requests
post '/:category?/:operation?' do
  category = params[:category]
  operation = params[:operation]
  data = JSON.parse request.body.read
  write_resource(data["content"])
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
