class Grammar < ActionController::Parameters
    def self.create(mtd, params)
        cls = Object.const_get(mtd.capitalize)
        cls.create(params)
    end
end

class Punctuator < Grammar
    def self.create(params)
        regex = /[^[:punct:]]/
        result = params[:text].gsub(regex, " ")
        { "result": result }
    end
end

class Isolator < Grammar
    def self.create(params)
        desired_punct =params.fetch(:punctuation)
        all_punct = "?<=!?.;"
        # raise KeyError unless desired_punct.length == 1
        print params[:text].split(/[#{all_punct}]/)
        params[:text].split(/[#{all_punct}]/).select { |s| s.last == desired_punct }.join(" ")
    end
end
