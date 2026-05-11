class Syntax < ActionController::Parameters
    def self.create(mtd, params)
        cls = Object.const_get(mtd.capitalize)
        cls.create(params)
    end
end

class Concordance < Syntax
    def self.create(params)
        word = params.fetch(:word)
        context = params.fetch(:context).to_i
        words = params[:text].split
        lines = []

        words.each_with_index do |w, idx|
            if w.downcase == word.downcase
                l_start = [ 0, idx - context ].max
                l_context = words[l_start...idx]
                r_end = [ words.length, idx + context + 1 ].min
                r_context = words[idx + 1...r_end]
                lines << "#{l_context.join(" ")} #{w} #{r_context.join(" ")}\n"
            end
        end

        lines.join
    end
end

class Abecedarian < Syntax
    def self.create(params)
        words = params[:text].split
        result = []
        current_letter = "a"
        used = Array.new(words.length, false)

        loop do
            found = false
            words.each_with_index do |w, idx|
                next if used[idx]
                if w.downcase.start_with?(current_letter)
                    result << w
                    used[idx] = true
                    current_letter = current_letter == "z" ? "a" : current_letter.next
                    found = true
                end
            end
            break unless found
        end

        result.join(" ")
    end
end

class Abcquence < Syntax
    def self.create(params)
        words = params[:text].split
        result = words.select do |w|
            letters = w.gsub(/[^a-zA-Z]/, "").downcase.chars
            letters == letters.sort
        end
        result.join(" ")
    end
end

class ChainReaction < Syntax
    def self.create(params)
        words = params[:text].split
        return "" if words.empty?

        result = []
        used = Array.new(words.length, false)

        # Start with the first word
        result << words[0]
        used[0] = true
        current_letter = words[0].downcase[-1]

        loop do
            found = false
            words.each_with_index do |w, idx|
                next if used[idx]
                if w.downcase.start_with?(current_letter)
                    result << w
                    used[idx] = true
                    current_letter = w.downcase[-1]
                    found = true
                    break
                end
            end
            break unless found
        end

        result.join(" ")
    end
end

class Anagram < Syntax
    DICT_PATH = Rails.root.join("data", "words_alpha.txt").to_s

    def self.dictionary
        @@dictionary ||= build_dictionary
    end

    def self.build_dictionary
        map = Hash.new { |h, k| h[k] = [] }
        if File.exist?(DICT_PATH)
            File.foreach(DICT_PATH, chomp: true) do |word|
                next if word.empty?
                key = word.downcase.chars.sort.join
                map[key] << word.downcase
            end
        end
        map
    end

    def self.create(params)
        dict = dictionary
        words = params[:text].split
        words.map do |w|
            match = w.match(/^(.*?)([a-zA-Z]+)(.*?)$/)
            next w unless match
            prefix, core, suffix = match[1], match[2], match[3]
            next w if core.length <= 2
            key = core.downcase.chars.sort.join
            candidates = dict[key] || []
            alternative = candidates.find { |c| c != core.downcase }
            next w unless alternative
            formatted = match_case(core, alternative)
            "#{prefix}#{formatted}#{suffix}"
        end.join(" ")
    end

    def self.match_case(original, replacement)
        return replacement.upcase if original == original.upcase
        if original[0] == original[0].upcase
            return replacement.capitalize
        end
        replacement
    end
end

class Alternator < Syntax
    def self.create(params)
        words = params[:text].split
        vowels = "aeiou"
        result = words.select do |w|
            letters = w.gsub(/[^a-zA-Z]/, "").downcase.chars
            next false if letters.length < 2
            pattern = letters.map { |c| vowels.include?(c) ? :v : :c }
            pattern.each_cons(2).all? { |a, b| a != b }
        end
        result.join(" ")
    end
end

class Hexwords < Syntax
    HEX_MAP = {
        "a" => "4", "b" => "8", "c" => "c", "d" => "d",
        "e" => "3", "f" => "f", "g" => "6", "i" => "1",
        "l" => "1", "o" => "0", "s" => "5", "t" => "7",
        "z" => "2"
    }.freeze

    def self.create(params)
        words = params[:text].split
        result = words.filter_map do |w|
            cleaned = w.gsub(/[^a-zA-Z0-9]/, "")
            next if cleaned.empty?

            if cleaned.match?(/\A[a-fA-F0-9]+\z/)
                cleaned.downcase
            else
                mapped = cleaned.downcase.chars.map do |c|
                    if c.match?(/\d/)
                        c
                    else
                        HEX_MAP[c]
                    end
                end

                next if mapped.include?(nil)
                mapped.join
            end
        end

        result.join(" ")
    end
end
