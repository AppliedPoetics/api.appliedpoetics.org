class Formic < ActionController::Parameters
  class PatternEngine
    def self.extract(text, mode: :words)
      return [] if text.nil? || text.strip.empty?

      case mode
      when :lines
        text.strip.split("\n")
      when :end_words
        lines = text.strip.split("\n")
        if lines.length >= 6
          lines.first(6).map { |line| line.split.last || "" }
        else
          text.split.first(6)
        end
      else
        text.split
      end
    end

    def self.arrange(items, sections, item_joiner: "\n", section_joiner: "\n\n")
      sections.map do |section|
        section.map { |i| items[i] }.join(item_joiner)
      end.join(section_joiner)
    end
  end
  private_constant :PatternEngine

  def self.create(mtd, params)
    cls = Object.const_get(mtd.capitalize)
    cls.create(params)
  end
end

class Sestina < Formic
  STANZA_PATTERN = [
    [ 0, 1, 2, 3, 4, 5 ],
    [ 5, 0, 4, 1, 3, 2 ],
    [ 2, 5, 3, 0, 1, 4 ],
    [ 4, 2, 1, 5, 0, 3 ],
    [ 3, 4, 0, 2, 5, 1 ],
    [ 1, 3, 5, 4, 2, 0 ]
  ].freeze

  ENVOI_PATTERN = [
    [ 1, 4 ],
    [ 3, 2 ],
    [ 5, 0 ]
  ].freeze

  def self.create(params)
    words = PatternEngine.extract(params[:text], mode: :end_words)
    unless words.length == 6
      raise ArgumentError, "Sestina requires exactly 6 end-words (found #{words.length})"
    end

    stanzas = PatternEngine.arrange(words, STANZA_PATTERN)
    envoi = PatternEngine.arrange(words, ENVOI_PATTERN, item_joiner: " ", section_joiner: "\n")
    { result: "#{stanzas}\n\n#{envoi}" }
  end
end

class Triolet < Formic
  LINE_PATTERN = [
    [ 0, 1, 2, 0, 3, 4, 0, 1 ]
  ].freeze

  def self.create(params)
    lines = PatternEngine.extract(params[:text], mode: :lines)
    unless lines.length >= 5
      raise ArgumentError, "Triolet requires at least 5 lines (found #{lines.length})"
    end

    { result: PatternEngine.arrange(lines.first(5), LINE_PATTERN) }
  end
end

class Pantoum < Formic
  def self.create(params)
    lines = PatternEngine.extract(params[:text], mode: :lines)
    unless lines.length >= 4
      raise ArgumentError, "Pantoum requires at least 4 lines (found #{lines.length})"
    end
    unless lines.length.even?
      raise ArgumentError, "Pantoum requires an even number of lines (found #{lines.length})"
    end

    num_stanzas = lines.length / 2
    pattern = build_pattern(num_stanzas)
    { result: PatternEngine.arrange(lines, pattern) }
  end

  def self.build_pattern(n)
    pattern = []
    n.times do |s|
      if s == 0
        pattern << [ 0, 1, 2, 3 ]
      elsif s == n - 1
        prev = pattern[s - 1]
        pattern << [ prev[1], 0, prev[3], 2 ]
      else
        prev = pattern[s - 1]
        pattern << [ prev[1], 2 * (s + 1), prev[3], 2 * (s + 1) + 1 ]
      end
    end
    pattern
  end
end
