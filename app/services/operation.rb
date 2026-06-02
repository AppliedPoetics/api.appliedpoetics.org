require "net/http"
require "uri"
require "json"

class Operation < ActionController::Parameters
    def self.create(mtd, params)
        class_name = mtd.split("_").map(&:capitalize).join
        cls = Object.const_get(class_name)
        cls.create(params)
    end
end

class Gutenberg < Operation
    START_MARKER = /\*{3,}\s*START OF (?:THIS|THE) PROJECT GUTENBERG EBOOK.*?\*{3,}/i
    END_MARKER = /\*{3,}\s*END OF (?:THIS|THE) PROJECT GUTENBERG EBOOK.*?\*{3,}/i

    def self.create(params)
        url = params.fetch(:url)
        uri = URI(url)
        body = Net::HTTP.get(uri)

        start_match = body.match(START_MARKER)
        end_match = body.match(END_MARKER)

        text = if start_match && end_match
            body[start_match.end(0)...end_match.begin(0)]
        elsif start_match
            body[start_match.end(0)..]
        elsif end_match
            body[...end_match.begin(0)]
        else
            body
        end

        { result: text.strip }
    rescue SocketError, Net::OpenTimeout, Net::ReadTimeout => e
        raise "Failed to download Gutenberg text: #{e.message}"
    end
end

class Wikipedia < Operation
    API_URL = "https://en.wikipedia.org/w/api.php".freeze

    def self.create(params)
        title = params.fetch(:title)
        uri = URI(API_URL)
        uri.query = URI.encode_www_form(
            action: "query",
            prop: "extracts",
            explaintext: "1",
            titles: title,
            format: "json",
            redirects: "1"
        )

        response = Net::HTTP.get(uri)
        data = JSON.parse(response)

        pages = data.dig("query", "pages")
        raise "No pages found in Wikipedia response" unless pages

        page = pages.values.first
        raise "Page not found: #{title}" if page["missing"]

        extract = page["extract"]
        raise "No extract available for page: #{title}" unless extract

        { result: extract }
    rescue JSON::ParserError => e
        raise "Invalid response from Wikipedia API: #{e.message}"
    rescue SocketError, Net::OpenTimeout, Net::ReadTimeout => e
        raise "Failed to connect to Wikipedia API: #{e.message}"
    end
end
