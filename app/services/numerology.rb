require "bigdecimal"
require "bigdecimal/math"

class Numerology < ActionController::Parameters
    def self.create(mtd, params)
        cls = Object.const_get(mtd.capitalize)
        cls.create(params)
    end
end

class Nth < Numerology
    def self.create(params)
        n = params.fetch(:n).to_i
        raise ArgumentError, "n must be a positive integer" unless n.positive?

        words = params[:text].split
        result = words.each_with_index.filter_map { |w, i| w if ((i + 1) % n).zero? }.join(" ")
        { result: result }
    end
end

class Pithon < Numerology
    def self.create(params)
        words = params[:text].split
        n = words.length
        result = n.zero? ? "3" : BigMath.PI(n + 1).round(n).to_s("F")
        { result: result }
    end
end

class Length < Numerology
    def self.create(params)
        n = params.fetch(:n).to_i
        raise ArgumentError, "n must be a positive integer" unless n.positive?

        words = params[:text].split
        result = words.select { |w| w.length == n }.join(" ")
        { result: result }
    end
end

class Birthday < Numerology
    def self.create(params)
        birthdate = params.fetch(:birthdate)
        unless birthdate.match?(/^\d{2}-\d{2}-\d{4}$/)
            raise ArgumentError, "birthdate must be in DD-MM-YYYY format"
        end

        digits = birthdate.delete("-").chars.map(&:to_i)
        words = params[:text].split
        count = words.length
        result = []
        pos = 0

        count.times do |i|
            d = digits[i % digits.length]
            pos = (pos + d) % count
            result << words[pos]
        end

        { result: result.join(" ") }
    end
end

class Phonewords < Numerology
    PHONE_MAP = {
        "2" => "ABC",
        "3" => "DEF",
        "4" => "GHI",
        "5" => "JKL",
        "6" => "MNO",
        "7" => "PQRS",
        "8" => "TUV",
        "9" => "WXYZ",
        "0" => "",
        "1" => ""
    }.freeze

    def self.create(params)
        phone = params.fetch(:phone).to_s
        unless phone.match?(/^\d{7}$/)
            raise ArgumentError, "phone must be a 7-digit number"
        end

        allowed = phone.chars.flat_map { |d| PHONE_MAP[d].chars }.to_set
        words = params[:text].split
        result = words.select { |w| w.gsub(/[^a-zA-Z]/, "").upcase.chars.all? { |c| allowed.include?(c) } }.join(" ")
        { result: result }
    end
end
