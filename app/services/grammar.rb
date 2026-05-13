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
        { result: result }
    end
end

class Isolator < Grammar
    def self.create(params)
        desired_punct =params.fetch(:punctuation)
        all_punct = "?<=!?.;"
        # raise KeyError unless desired_punct.length == 1
        result = params[:text].split(/[#{all_punct}]/).select { |s| s.last == desired_punct }.join(" ")
        { result: result }
    end
end

class Quotations < Grammar
    def self.create(params)
        result = params[:text].scan(/"([^"]*)"/).flatten.join(" ")
        { result: result }
    end
end

class PartsOfSpeech < Grammar
    VALID_TAGS = %w[
        adjectives adverbs base_present_verbs comparative_adjectives
        conjunctions gerund_verbs infinitive_verbs interrogatives
        max_noun_phrases noun_phrases nouns passive_verbs past_tense_verbs
        present_verbs proper_nouns question_parts superlative_adjectives
        verbs words
    ].freeze

    def self.create(params)
        part_of_speech = params.fetch(:tag)
        unless VALID_TAGS.include?(part_of_speech)
            raise ArgumentError, "Invalid part of speech: #{part_of_speech}. Valid tags: #{VALID_TAGS.join(', ')}"
        end
        require "engtagger"
        tgr = EngTagger.new
        tagged = tgr.add_tags(params[:text])
        result = tgr.public_send("get_#{part_of_speech}", tagged).keys.join(" ")
        { result: result }
    end
end
