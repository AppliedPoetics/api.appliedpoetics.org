# Gemfile libraries
require 'sinatra'
require 'sinatra/namespace'

require 'fileutils'
require 'require_all'
require 'include_all'
require 'securerandom'

require_all 'methods'
include_all

namespace '/v1' do

  helpers do

    def parse_content(request)
      data = JSON.parse request.body.read
      data["content"]
    end

    def write_resource(content)
      name = SecureRandom.uuid
      FileUtils.mkdir_p 'resources'
      begin
        File.open("resources/#{name}", "w") {
          |file| file.write(content)
        }
      rescue => e
        # Do nothing
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

  end

  # Process calls to valid endpoints; fence out
  # all of the bad requests
  post '/:cat/:op' do
    # Setup
    op = params[:op]
    cat = params[:cat]
    uuid = write_resource(
      parse_content(request)
    )
    # Operations
    begin
      response = :cat.public_send(
        op,
        read_resource(uuid)
      )
      status 200
      JSON({
        res: response
      })
    rescue NoMethodError => e
      status 418
      JSON({
        res: "Bad method"
      })
    ensure
      delete_resource(uuid)
    end
  end

end
