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

class Weatherizer < Pop
    TERMS_PATH = Rails.root.join("data", "weather_terms.txt").to_s

    def self.terms
        @@terms ||= load_terms
    end

    def self.load_terms
        terms = []
        if File.exist?(TERMS_PATH)
            File.foreach(TERMS_PATH, chomp: true) do |line|
                terms << line.strip unless line.strip.empty?
            end
        end
        terms
    end

    def self.create(params)
        text = params[:text]
        return { result: "" } if text.nil? || text.strip.empty?

        terms_regex = Regexp.union(terms.map { |t| /\b#{Regexp.escape(t)}\b/i })
        sentences = text.split(/(?<=[.!?])\s+/)
        result = sentences.select { |s| s.match?(terms_regex) }
        { result: result.join(" ") }
    end
end

class Colorizer < Pop
    COLORS_PATH = Rails.root.join("data", "colors.txt").to_s

    def self.color_names
        @@color_names ||= load_color_names
    end

    def self.load_color_names
        names = []
        if File.exist?(COLORS_PATH)
            File.foreach(COLORS_PATH, chomp: true) do |line|
                name = line.split.first
                names << name if name && !name.empty?
            end
        end
        names
    end

    def self.create(params)
        text = params[:text]
        return { result: "" } if text.nil? || text.strip.empty?

        colors_regex = Regexp.union(color_names.map { |c| /\b#{Regexp.escape(c)}\b/i })
        sentences = text.split(/(?<=[.!?])\s+/)
        result = sentences.select { |s| s.match?(colors_regex) }
        { result: result.join(" ") }
    end
end

class Sartorializer < Pop
    TERMS_PATH = Rails.root.join("data", "fashion_terms.txt").to_s

    def self.terms
        @@terms ||= load_terms
    end

    def self.load_terms
        terms = []
        if File.exist?(TERMS_PATH)
            File.foreach(TERMS_PATH, chomp: true) do |line|
                terms << line.strip unless line.strip.empty?
            end
        end
        terms
    end

    def self.create(params)
        text = params[:text]
        return { result: "" } if text.nil? || text.strip.empty?

        terms_regex = Regexp.union(terms.map { |t| /\b#{Regexp.escape(t)}\b/i })
        sentences = text.split(/(?<=[.!?])\s+/)
        result = sentences.select { |s| s.match?(terms_regex) }
        { result: result.join(" ") }
    end
end
