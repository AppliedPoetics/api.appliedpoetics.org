require "net/http"
require "json"
require "uri"

class Pop < ActionController::Parameters
    def self.create(mtd, params)
        cls = Object.const_get(mtd.capitalize)
        cls.create(params)
    end
end

class Powerball < Pop
    API_URL = "https://data.ny.gov/resource/d6yy-54nr.json".freeze

    def self.create(params)
        numbers = fetch_numbers
        words = params[:text].split
        count = words.length
        return { result: "" } if count.zero?

        result = []
        pos = 0

        count.times do |i|
            n = numbers[i % numbers.length]
            pos = (pos + n) % count
            result << words[pos]
        end

        { result: result.join(" ") }
    end

    def self.fetch_numbers
        uri = URI(API_URL)
        response = Net::HTTP.get(uri)
        data = JSON.parse(response)
        latest = data.first
        raise "No Powerball data found" unless latest
        latest["winning_numbers"].split.map(&:to_i)
    rescue JSON::ParserError => e
        raise "Invalid response from lottery API: #{e.message}"
    rescue SocketError, Net::OpenTimeout, Net::ReadTimeout => e
        raise "Failed to connect to lottery API: #{e.message}"
    end
end
