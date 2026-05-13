class McpToolRegistry
    BASE_SCHEMA = {
        text: { type: "string", description: "The text to process" }
    }.freeze

    SCHEMA_OVERRIDES = {
        "syntax_concordance" => {
            text: { type: "string", description: "The text to analyze" },
            word: { type: "string", description: "The target word" },
            context: { type: "integer", description: "Number of surrounding words to include" }
        },
        "grammar_isolator" => {
            text: { type: "string" },
            punctuation: { type: "string", description: "Punctuation delimiter to filter by" }
        },
        "grammar_parts_of_speech" => {
            text: { type: "string" },
            tag: { type: "string", description: "Part of speech tag (e.g., nouns, verbs, adjectives, adverbs)" }
        },
        "oulipean_lipogram" => {
            text: { type: "string" },
            letters: { type: "string", description: "Letters to exclude from the text" }
        },
        "oulipean_tautogram" => {
            text: { type: "string" },
            letters: { type: "string", description: "Letters that words must contain" }
        },
        "oulipean_belle_absente" => {
            text: { type: "string" },
            letters: { type: "string", description: "Letters to exclude from the text" }
        },
        "oulipean_beau_presente" => {
            text: { type: "string" },
            letters: { type: "string", description: "Letters that words must contain" }
        },
        "oulipean_univocalism" => {
            text: { type: "string" },
            letters: { type: "string", description: "The single vowel to preserve" }
        },
        "oulipean_snowball" => {
            text: { type: "string" },
            order: { type: "string", enum: [ "asc", "desc" ], description: "Sort order by word length" }
        },
        "numerology_nth" => {
            text: { type: "string" },
            n: { type: "integer", description: "Return every nth word" }
        },
        "numerology_length" => {
            text: { type: "string" },
            n: { type: "integer", description: "Target word length in letters" }
        },
        "numerology_birthday" => {
            text: { type: "string" },
            birthdate: { type: "string", description: "Date in DD-MM-YYYY format" }
        },
        "numerology_phonewords" => {
            text: { type: "string" },
            phone: { type: "string", description: "7-digit phone number" }
        },
        "algorithmic_levenshtein" => {
            text: { type: "string" },
            distance: { type: "integer", description: "Maximum Levenshtein edit distance" }
        },
        "algorithmic_color_field" => {
            text: { type: "string" },
            image: { type: "string", description: "Image data or file path" },
            mode: { type: "string", enum: [ "sentences", "letters", "anagrams", "list" ], description: "Processing mode" }
        }
    }.freeze

    CATEGORIES = {
        "syntax" => Syntax,
        "grammar" => Grammar,
        "oulipean" => Oulipean,
        "numerology" => Numerology,
        "pop" => Pop,
        "algorithmic" => Algorithmic,
        "formic" => Formic
    }.freeze

    RESOURCES = [
        { uri: "data://colors.txt", name: "CSS Color Names", mimeType: "text/plain", description: "List of CSS color names with RGB values" },
        { uri: "data://weather_terms.txt", name: "Weather Terms", mimeType: "text/plain", description: "Comprehensive meteorological terminology" },
        { uri: "data://fashion_terms.txt", name: "Fashion Terms", mimeType: "text/plain", description: "Clothing and fashion terminology" },
        { uri: "data://words_alpha.txt", name: "English Words Dictionary", mimeType: "text/plain", description: "Alphabetical list of English words" }
    ].freeze

    def self.tools
        tools = []
        CATEGORIES.each do |cat_name, base_class|
            base_class.subclasses.each do |subclass|
                tool_name = "#{cat_name}_#{camel_to_snake(subclass.name)}"
                schema = SCHEMA_OVERRIDES[tool_name] || BASE_SCHEMA.dup
                tools << {
                    name: tool_name,
                    description: tool_description(tool_name, subclass.name),
                    inputSchema: {
                        type: "object",
                        properties: schema,
                        required: schema.keys
                    }
                }
            end
        end
        tools
    end

    def self.call(tool_name, arguments)
        _cat, method = tool_name.split("_", 2)
        class_name = snake_to_camel(method)
        cls = Object.const_get(class_name)
        params = ActionController::Parameters.new(arguments)
        cls.create(params)
    end

    def self.resources
        RESOURCES
    end

    def self.read_resource(uri)
        path = Rails.root.join("data", uri.sub("data://", ""))
        return nil unless File.exist?(path)
        File.read(path)
    end

    private

    def self.camel_to_snake(str)
        str.gsub(/([A-Z])/, '_\1').downcase.sub(/^_/, "")
    end

    def self.snake_to_camel(str)
        str.split("_").map(&:capitalize).join
    end

    def self.tool_description(tool_name, class_name)
        case class_name
        when "Concordance"
            "Finds occurrences of a word with surrounding context"
        when "Abecedarian"
            "Selects words in alphabetical order by first letter"
        when "Abcquence"
            "Selects words whose letters are in alphabetical order"
        when "ChainReaction"
            "Links words where the last letter of one matches the first of the next"
        when "Anagram"
            "Replaces words with dictionary anagrams when available"
        when "Alternator"
            "Selects words that alternate between vowels and consonants"
        when "Hexwords"
            "Translates words into hex-style leetspeak spellings"
        when "Punctuator"
            "Extracts only punctuation marks from text"
        when "Isolator"
            "Filters text fragments by ending punctuation"
        when "Quotations"
            "Extracts text inside double quotes"
        when "PartsOfSpeech"
            "Extracts words by grammatical category"
        when "Lipogram"
            "Excludes words containing specified letters"
        when "Tautogram"
            "Includes only words containing specified letters"
        when "Homoconsonantism"
            "Excludes words containing vowels"
        when "Fibonacci"
            "Selects words at Fibonacci positions"
        when "Prisoner"
            "Excludes words with letters that descend below the baseline"
        when "BelleAbsente"
            "Excludes words containing specified letters (lipogram variant)"
        when "BeauPresente"
            "Includes only words containing specified letters (tautogram variant)"
        when "Univocalism"
            "Removes words containing unwanted vowels"
        when "Snowball"
            "Sorts words by length in ascending or descending order"
        when "Nth"
            "Selects every nth word from the text"
        when "Pithon"
            "Returns pi to as many decimal places as there are words"
        when "Length"
            "Selects words of a specific letter count"
        when "Birthday"
            "Selects words using birthdate digits as step values"
        when "Phonewords"
            "Selects words spellable on a phone keypad"
        when "Powerball"
            "Selects words using NY lottery Powerball numbers as steps"
        when "Weatherizer"
            "Selects sentences containing weather terminology"
        when "Colorizer"
            "Selects sentences containing color names"
        when "Sartorializer"
            "Selects sentences containing fashion and clothing terms"
        when "Levenshtein"
            "Finds word pairs within a given edit distance"
        when "ColorField"
            "Analyzes image colors and filters text accordingly"
        when "Sestina"
            "Arranges end-words into a sestina pattern"
        when "Triolet"
            "Arranges lines into a triolet form"
        when "Pantoum"
            "Arranges lines into a pantoum form"
        else
            "Applies the #{class_name} constraint to text"
        end
    end
end
