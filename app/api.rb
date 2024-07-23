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
    0
  end
  name
end

def read_resource(uuid)
  name = "resources/#{uuid}"
  File.read(name) if File.exist?(name)
end

def delete_resource(uuid)
  name = "resources/#{uuid}"
  File.delete(name) if File.exist?(name)
end

# Process calls to valid endpoints; fence out
# all of the bad requests
post '/:category?/:operation?' do
  category = params[:category]
  operation = params[:operation]
  data = JSON.parse request.body.read
  uuid = write_resource(data["content"])
  begin
    response = :category.public_send(operation, read_resource(uuid))
    status 200
    JSON({
      res: response
    })
  rescue NoMethodError => e
    puts e
    status 418
    JSON({
      res: "Bad method"
    })
  ensure
    delete_resource(uuid)
  end
end
