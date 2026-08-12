require "test_helper"

class AlgorithmicTest < ActiveSupport::TestCase
  test "Levenshtein finds pairs within distance 1" do
    result = Levenshtein.create({
      text: "cat bat hat dog",
      distance: 1
    })[:result]
    assert_includes result, "cat bat"
    assert_includes result, "cat hat"
    assert_includes result, "bat hat"
    assert_not_includes result.split("\n"), "dog"
  end

  test "Levenshtein finds pairs within distance 2" do
    result = Levenshtein.create({
      text: "cat cut cute",
      distance: 2
    })[:result]
    assert_includes result, "cat cut"
    assert_includes result, "cut cute"
    assert_includes result, "cat cute"
  end

  test "Levenshtein ignores duplicate words" do
    result = Levenshtein.create({
      text: "cat cat bat",
      distance: 1
    })[:result]
    lines = result.split("\n")
    assert_equal 1, lines.length
    assert_includes result, "cat bat"
  end

  def create_test_image
    image = ChunkyPNG::Image.new(10, 10)
    (0...10).each do |y|
      (0...5).each { |x| image[x, y] = ChunkyPNG::Color.rgb(255, 0, 0) }
      (5...10).each { |x| image[x, y] = ChunkyPNG::Color.rgb(0, 0, 255) }
    end
    StringIO.new(image.to_blob)
  end

  test "ColorField sentences mode returns sentences containing color names" do
    image = create_test_image
    result = ColorField.create({
      image: image,
      text: "The red fox jumped. The grass is green. The sky is blue.",
      mode: "sentences"
    })[:result]
    assert_includes result, "red"
    assert_includes result, "blue"
    assert_not_includes result, "green"
  end

  test "ColorField letters mode returns words using only letters from color names" do
    image = create_test_image
    result = ColorField.create({
      image: image,
      text: "red blue rude rebel test hello",
      mode: "letters"
    })[:result]
    assert_includes result.split, "red"
    assert_includes result.split, "blue"
    assert_includes result.split, "rude"
    assert_includes result.split, "rebel"
    assert_not_includes result.split, "test"
    assert_not_includes result.split, "hello"
  end

  test "ColorField anagrams mode returns anagrams of color names" do
    image = create_test_image
    result = ColorField.create({
      image: image,
      text: "red der blue bleu test",
      mode: "anagrams"
    })[:result]
    assert_includes result.split, "red"
    assert_includes result.split, "der"
    assert_includes result.split, "blue"
    assert_includes result.split, "bleu"
    assert_not_includes result.split, "test"
  end

  test "ColorField list mode returns color names" do
    image = create_test_image
    result = ColorField.create({
      image: image,
      text: "",
      mode: "list"
    })[:result]
    assert_includes result.split, "red"
    assert_includes result.split, "blue"
  end

  test "Markov returns empty result for empty text" do
    result = Markov.create({
      text: "",
      order: 2,
      length: 50
    })[:result]
    assert_equal "", result
  end

  test "Markov returns original text when shorter than order" do
    result = Markov.create({
      text: "ab",
      order: 3,
      length: 50
    })[:result]
    assert_equal "ab", result
  end

  test "Markov generates only characters present in input" do
    text = "abracadabra"
    result = Markov.create({
      text: text,
      order: 2,
      length: 20
    })[:result]
    result.chars.each do |char|
      assert_includes text.chars, char
    end
  end

  test "Markov output length is bounded by order plus length" do
    text = "the quick brown fox jumps over the lazy dog"
    length = 10
    result = Markov.create({
      text: text,
      order: 2,
      length: length
    })[:result]
    assert result.length <= 2 + length
  end

  test "Markov terminates early when chain has no follower" do
    result = Markov.create({
      text: "abc",
      order: 2,
      length: 50
    })[:result]
    assert_equal "abc", result
  end

  test "Markov expands uniform input deterministically" do
    result = Markov.create({
      text: "zzzzzzzzzz",
      order: 2,
      length: 20
    })[:result]
    assert_equal "z" * 22, result
  end

  test "ColorField accepts an image URL" do
    image_blob = create_test_image.read
    original = ColorField.method(:download_image_url)
    ColorField.define_singleton_method(:download_image_url) { |_| image_blob }

    result = ColorField.create({
      image: "https://example.com/image.png",
      text: "",
      mode: "list"
    })[:result]
    assert_includes result.split, "red"
    assert_includes result.split, "blue"
  ensure
    ColorField.define_singleton_method(:download_image_url) { |*args| original.call(*args) }
  end

  test "ColorField accepts a base64 data URL" do
    image_blob = create_test_image.read
    data_url = "data:image/png;base64,#{Base64.encode64(image_blob)}"

    result = ColorField.create({
      image: data_url,
      text: "",
      mode: "list"
    })[:result]
    assert_includes result.split, "red"
    assert_includes result.split, "blue"
  end

  test "ColorField accepts a multipart-style uploaded file" do
    image_blob = create_test_image.read
    tempfile = Tempfile.new([ "upload", ".png" ], binmode: true)
    tempfile.write(image_blob)
    tempfile.rewind
    upload = Rack::Test::UploadedFile.new(tempfile.path, "image/png")

    result = ColorField.create({
      image: upload,
      text: "",
      mode: "list"
    })[:result]
    assert_includes result.split, "red"
    assert_includes result.split, "blue"
  ensure
    tempfile&.close
    tempfile&.unlink
  end

  test "ColorField rejects non-image data" do
    assert_raises(ArgumentError) do
      ColorField.create({
        image: "this is not an image",
        text: "",
        mode: "list"
      })
    end
  end

  test "ColorField rejects local file path strings" do
    assert_raises(ArgumentError) do
      ColorField.create({
        image: "/etc/passwd",
        text: "",
        mode: "list"
      })
    end
  end

  test "ColorField rejects non-HTTP URL schemes" do
    assert_raises(ArgumentError) do
      ColorField.create({
        image: "ftp://example.com/image.png",
        text: "",
        mode: "list"
      })
    end
  end

  test "ColorField rejects oversized images" do
    assert_raises(ArgumentError) do
      ColorField.create({
        image: "a" * (ColorField::MAX_IMAGE_SIZE + 1),
        text: "",
        mode: "list"
      })
    end
  end
end
