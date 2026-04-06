class Oulipean < ActionController::Parameters
    
    def self.create(mtd, params)
        cls = Object.const_get(mtd.capitalize)
        cls.create(params)
    end
    
    def self.exclude_words(text, letters)
        regex = Regexp.union(letters)
        result = text.split.reject { |w| w.downcase.match?(regex) }
        {"result": result.join(" ")}
    end

    def self.include_words(text, letters)
        regex = Regexp.union(letters)
        result = text.split.select { |w| w.downcase.match?(regex) }
        {"result": result.join(" ")}
    end

end

class Lipogram < Oulipean

    def self.create(params)
        params.fetch(:letters)
        letters = params[:letters].chars
        self.exclude_words(params[:text], letters)
    end 

end

class Tautogram < Oulipean

    def self.create(params)
        params.fetch(:letters)
        letters = params[:letters].chars
        self.include_words(params[:text], letters)
    end 

end