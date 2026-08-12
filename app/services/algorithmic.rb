class Algorithmic < ActionController::Parameters
    def self.create(mtd, params)
        class_name = mtd.split("_").map(&:capitalize).join
        cls = Object.const_get(class_name)
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

        { result: pairs.join("\n") }
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
require "mini_magick"
require "net/http"
require "base64"
require "tempfile"
require "uri"

class ColorField < Algorithmic
    COLORS_PATH = Rails.root.join("data", "colors.txt").to_s
    MAX_IMAGE_SIZE = 10.megabytes
    VALID_IMAGE_MAGIC_BYTES = [
        "\x89PNG".b,        # PNG
        "\xFF\xD8\xFF".b,   # JPEG
        "GIF8".b,           # GIF
        "RIFF".b,           # WebP
        "BM".b              # BMP
    ].freeze

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

        result = case mode
        when "sentences"
            sentences_mode(text, color_names)
        when "letters"
            letters_mode(text, color_names)
        when "anagrams"
            anagrams_mode(text, color_names)
        when "list"
            list_mode(color_names)
        end

        { result: result }
    end

    private

    def self.extract_color_names(image)
        source_path = materialize_image(image)
        png_path = convert_to_png(source_path)
        png = ChunkyPNG::Image.from_blob(File.binread(png_path.path))
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
    ensure
        source_path&.close
        source_path&.unlink
        png_path&.close
        png_path&.unlink
    end

    def self.materialize_image(image)
        blob = case image
        when ActionDispatch::Http::UploadedFile, Rack::Test::UploadedFile
            read_uploaded_file(image)
        when String
            if image.start_with?("data:")
                parse_data_url(image)
            elsif url?(image)
                download_image_url(image)
            elsif image.match?(/\A[a-z][a-z0-9+.-]*:/i)
                raise ArgumentError, "Only HTTP/HTTPS URLs are supported"
            else
                image
            end
        else
            image.respond_to?(:read) ? read_io(image) : image.to_s
        end

        validate_image_blob!(blob)

        tempfile = Tempfile.new([ "colorfield_source", ".bin" ], binmode: true)
        tempfile.write(blob)
        tempfile.flush
        tempfile.rewind
        tempfile
    end

    def self.read_uploaded_file(upload)
        tempfile = upload.tempfile
        tempfile.binmode
        tempfile.rewind
        tempfile.read
    end

    def self.read_io(io)
        io.read
    end

    def self.parse_data_url(data_url)
        match = data_url.match(/\Adata:(.*?)(?:;base64)?,(.*)\z/m)
        raise ArgumentError, "Invalid data URL" unless match

        media_type, data = match[1], match[2]
        unless media_type.start_with?("image/")
            raise ArgumentError, "Data URL must be an image type"
        end

        if data_url.include?(";base64")
            Base64.decode64(data)
        else
            URI.decode_www_form_component(data)
        end
    end

    def self.download_image_url(url_string)
        uri = URI.parse(url_string)
        raise ArgumentError, "Only HTTP/HTTPS URLs are supported" unless %w[http https].include?(uri.scheme)

        response = Net::HTTP.start(
            uri.hostname,
            uri.port,
            use_ssl: uri.scheme == "https",
            open_timeout: 10,
            read_timeout: 10
        ) do |http|
            http.request(Net::HTTP::Get.new(uri))
        end

        raise "Image download failed: HTTP #{response.code}" unless response.is_a?(Net::HTTPSuccess)

        body = response.body
        raise ArgumentError, "Image too large (max 10 MB)" if body.bytesize > MAX_IMAGE_SIZE

        body
    rescue URI::InvalidURIError => e
        raise ArgumentError, "Invalid image URL: #{e.message}"
    rescue SocketError, Net::OpenTimeout, Net::ReadTimeout => e
        raise "Failed to download image: #{e.message}"
    end

    def self.url?(string)
        URI.parse(string)
        %w[http https].include?(URI.parse(string).scheme)
    rescue URI::InvalidURIError
        false
    end

    def self.validate_image_blob!(blob)
        blob = blob.to_s.b
        raise ArgumentError, "Empty image data" if blob.empty?
        raise ArgumentError, "Image too large (max 10 MB)" if blob.bytesize > MAX_IMAGE_SIZE

        unless VALID_IMAGE_MAGIC_BYTES.any? { |magic| blob.start_with?(magic) }
            raise ArgumentError, "File does not appear to be a valid image"
        end
    end

    def self.convert_to_png(source_path)
        output = Tempfile.new([ "colorfield", ".png" ], binmode: true)
        image = MiniMagick::Image.open(source_path.path)
        image.format("png")
        image.write(output.path)
        image.destroy!
        output
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

        text.split("\n").map do |line|
            sentences = line.split(/(?<=[.!?])\s+/)
            sentences.select do |sentence|
                color_names.any? { |color| sentence.downcase.include?(color) }
            end.join(" ")
        end.join("\n")
    end

    def self.letters_mode(text, color_names)
        return "" if text.empty? || color_names.empty?

        allowed = color_names.join.downcase.chars.uniq.sort.join
        regex = /\A[#{Regexp.escape(allowed)}]+\z/i
        text.split("\n").map do |line|
            line.split.select { |word| word.gsub(/[^a-zA-Z]/, "").match?(regex) }.join(" ")
        end.join("\n")
    end

    def self.anagrams_mode(text, color_names)
        return "" if text.empty? || color_names.empty?

        color_keys = color_names.map { |name| name.downcase.chars.sort.join }.to_set

        text.split("\n").map do |line|
            line.split.select do |word|
                core = word.downcase.gsub(/[^a-z]/, "")
                next false if core.empty?
                color_keys.include?(core.chars.sort.join)
            end.join(" ")
        end.join("\n")
    end

    def self.list_mode(color_names)
        color_names.join(" ")
    end
end

class Markov < Algorithmic
    DEFAULT_ORDER = 2
    DEFAULT_LENGTH = 50

    def self.create(params)
        text = params.fetch(:text)
        order = params.fetch(:order, DEFAULT_ORDER).to_i
        length = params.fetch(:length, DEFAULT_LENGTH).to_i

        return { result: "" } if text.nil? || text.empty?
        return { result: text } if text.length <= order

        model = build_model(text, order)
        state = model.keys.sample
        output = state.dup

        length.times do
            followers = model[state]
            break if followers.nil? || followers.empty?

            next_char = followers.sample
            output << next_char
            state = state[1..-1] + next_char
        end

        { result: output }
    end

    def self.build_model(text, order)
        model = Hash.new { |h, k| h[k] = [] }
        chars = text.chars

        (0..chars.length - order - 1).each do |i|
            state = chars[i, order].join
            next_char = chars[i + order]
            model[state] << next_char
        end

        model
    end
end
