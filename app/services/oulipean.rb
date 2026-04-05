class Oulipean
    
    def self.create(mtd, params)
        cls = Object.const_get(mtd.capitalize)
        cls.create(params)
    end
    
    def self.exclude(text, letters)
        result = text.chars.reject { |c| letters.include?(c) }.join
        {"result": result}
    end

end

class Lipogram < Oulipean

    def self.create(params)
        self.exclude(params["text"], params["letters"])
    end 

end

class Tautogram < Oulipean

    def self.create(params)
        self.exclude(params["text"], params["letters"])
    end 

end