class Oulipean < ActionController::Parameters
    @@vowels = "aeiou"

    def self.create(mtd, params)
        cls = Object.const_get(mtd.capitalize)
        cls.create(params)
    end

    def self.exclude_words(text, letters)
        regex = Regexp.union(letters)
        result = text.split.reject { |w| w.downcase.match?(regex) }
        { result: result.join(" ") }
    end

    def self.include_words(text, letters)
        regex = Regexp.union(letters)
        result = text.split.select { |w| w.downcase.match?(regex) }
        { result: result.join(" ") }
    end

    def self.vowels
        @@vowels
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

class Homoconsonantism < Oulipean
    def initialize
        super
    end

    def self.create(params)
        letters = Oulipean.vowels.chars
        self.exclude_words(params[:text], letters)
    end
end

class Fibonacci < Oulipean
    def self.create(params)
        words = params[:text].split
        fibs = [ 1, 1 ]
        while fibs.last <= words.length
            fibs << fibs[-1] + fibs[-2]
        end
        result = fibs.select { |n| n <= words.length }.map { |n| words[n - 1] }
        { result: result.join(" ") }
    end
end

class Prisoner < Oulipean
    def self.create(params)
        # List of exiled characters
        letters = "bdfghjklpqty0123456789".chars
        self.exclude_words(params[:text], letters)
    end
end

class BelleAbsente < Oulipean
    def self.create(params)
        letters = params.fetch(:letters).chars
        self.exclude_words(params[:text], letters)
    end
end

class BeauPresente < Oulipean
    def self.create(params)
        letters = params.fetch(:letters).chars
        self.include_words(params[:text], letters)
    end
end

class Univocalism < Oulipean
    def initialize
        super
    end

    def self.create(params)
        letter = params.fetch(:letters).chars.first
        letters = Oulipean.vowels.chars.reject { |l| l != letter }
        result = params[:text].gsub(/\w*#{letters}\w*/i, " ")
        { result: result }
    end
end

class Snowball < Oulipean
    def self.create(params)
        order = params.fetch(:order)
        if order == "asc"
            result = params[:text].split.sort_by(&:length).join(" ")
        elsif order == "desc"
            result = params[:text].split.sort_by(&:length).reverse.join(" ")
        end
        { result: result }
    end
end
