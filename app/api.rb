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
  FileUtils.makedir_p 'resources'
  name = securerandom.hex
  begin
    File.open("resources/#{name}", "w") {
      |file| file.write(content)
    }
  rescue => e
    false
  end
  true
end

def acquire_content(data)
  data.body.rewind
  body = JSON.parse data.read
  puts body
end

# Process calls to valid endpoints; fence out
# all of the bad requests
post '/:category?/:operation?' do
  category = params[:category]
  operation = params[:operation]
  puts JSON.parse request.body.read
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
