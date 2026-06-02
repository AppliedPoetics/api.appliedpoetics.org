class Grammar < ActionController::Parameters
    def self.create(mtd, params)
        class_name = mtd.split("_").map(&:capitalize).join
        cls = Object.const_get(class_name)
        cls.create(params)
    end
end

class Punctuator < Grammar
    def self.create(params)
        regex = /[^[:punct:]]/
        result = params[:text].split("\n").map { |line| line.gsub(regex, " ") }.join("\n")
        { result: result }
    end
end

class Isolator < Grammar
    def self.create(params)
        desired_punct = params.fetch(:punctuation)
        all_punct = "?<=!?.;"
        # raise KeyError unless desired_punct.length == 1
        result = params[:text].split("\n").map do |line|
            line.split(/[#{all_punct}]/).select { |s| s.last == desired_punct }.join(" ")
        end.join("\n")
        { result: result }
    end
end

class Quotations < Grammar
    def self.create(params)
        result = params[:text].split("\n").map do |line|
            line.scan(/"([^"]*)"/).flatten.join(" ")
        end.join("\n")
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
        result = params[:text].split("\n").map do |line|
            tagged = tgr.add_tags(line)
            tgr.public_send("get_#{part_of_speech}", tagged).keys.join(" ")
        end.join("\n")
        { result: result }
    end
end
