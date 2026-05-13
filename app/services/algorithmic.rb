class Algorithmic < ActionController::Parameters
    def self.create(mtd, params)
        cls = Object.const_get(mtd.capitalize)
        cls.create(params)
    end
end

class Levenshtein < Algorithmic
    def self.create(params)
        words = params[:text].split.uniq
        max_distance = params.fetch(:distance).to_i

        pairs = []
        words.each_with_index do |w1, i|
            words.each_with_index do |w2, j|
                next unless j > i
                if self.distance(w1.downcase, w2.downcase) <= max_distance
                    pairs << "#{w1} #{w2}"
                end
            end
        end

        pairs.join("\n")
    end

    def self.distance(a, b)
        m = a.length
        n = b.length
        return n if m == 0
        return m if n == 0

        previous = (0..n).to_a
        current = Array.new(n + 1, 0)

        (1..m).each do |i|
            current[0] = i
            (1..n).each do |j|
                cost = a[i - 1] == b[j - 1] ? 0 : 1
                current[j] = [
                    current[j - 1] + 1,
                    previous[j] + 1,
                    previous[j - 1] + cost
                ].min
            end
            previous, current = current, previous
        end

        previous[n]
    end
end

require "chunky_png"
require "set"

class ColorField < Algorithmic
    COLORS_PATH = Rails.root.join("data", "colors.txt").to_s

    def self.css_colors
        @@css_colors ||= load_colors
    end

    def self.load_colors
        colors = {}
        if File.exist?(COLORS_PATH)
            File.foreach(COLORS_PATH, chomp: true) do |line|
                next if line.empty?
                parts = line.split
                next if parts.length < 4
                name = parts[0]
                rgb = parts[1..3].map(&:to_i)
                colors[name] = rgb
            end
        end
        colors
    end

    VALID_MODES = %w[sentences letters anagrams list].freeze

    def self.create(params)
        image = params[:image]
        text = params.fetch(:text, "")
        mode = params.fetch(:mode)

        unless VALID_MODES.include?(mode)
            raise ArgumentError, "Invalid mode: #{mode}. Valid modes: #{VALID_MODES.join(', ')}"
        end

        color_names = extract_color_names(image)

        case mode
        when "sentences"
            sentences_mode(text, color_names)
        when "letters"
            letters_mode(text, color_names)
        when "anagrams"
            anagrams_mode(text, color_names)
        when "list"
            list_mode(color_names)
        end
    end

    private

    def self.read_image(image)
        blob = if image.respond_to?(:read)
            image.read
        elsif image.is_a?(String)
            if File.exist?(image)
                File.binread(image)
            else
                image
            end
        else
            image.to_s
        end

        ChunkyPNG::Image.from_blob(blob)
    end

    def self.extract_color_names(image)
        png = read_image(image)
        width = png.width
        height = png.height

        # Determine sample step to keep processing reasonable
        total_pixels = width * height
        step = if total_pixels <= 1000
            1
        else
            [ 1, Math.sqrt(total_pixels / 1000.0).ceil ].max
        end

        unique_pixels = Set.new
        (0...height).step(step) do |y|
            (0...width).step(step) do |x|
                unique_pixels << png[x, y]
            end
        end

        unique_pixels.map { |pixel| nearest_color_name(pixel) }.compact.uniq
    end

    def self.nearest_color_name(pixel)
        r = ChunkyPNG::Color.r(pixel)
        g = ChunkyPNG::Color.g(pixel)
        b = ChunkyPNG::Color.b(pixel)

        nearest_name = nil
        min_distance = Float::INFINITY

        css_colors.each do |name, rgb|
            dist = (r - rgb[0])**2 + (g - rgb[1])**2 + (b - rgb[2])**2
            if dist < min_distance
                min_distance = dist
                nearest_name = name
            end
        end

        nearest_name
    end

    def self.sentences_mode(text, color_names)
        return "" if text.empty? || color_names.empty?

        sentences = text.split(/(?<=[.!?])\s+/)
        sentences.select do |sentence|
            color_names.any? { |color| sentence.downcase.include?(color) }
        end.join(" ")
    end

    def self.letters_mode(text, color_names)
        return "" if text.empty? || color_names.empty?

        allowed = color_names.join.downcase.chars.uniq.sort.join
        regex = /\A[#{Regexp.escape(allowed)}]+\z/i
        text.split.select { |word| word.gsub(/[^a-zA-Z]/, "").match?(regex) }.join(" ")
    end

    def self.anagrams_mode(text, color_names)
        return "" if text.empty? || color_names.empty?

        color_keys = color_names.map { |name| name.downcase.chars.sort.join }.to_set

        text.split.select do |word|
            core = word.downcase.gsub(/[^a-z]/, "")
            next false if core.empty?
            color_keys.include?(core.chars.sort.join)
        end.join(" ")
    end

    def self.list_mode(color_names)
        color_names.join(" ")
    end
end
