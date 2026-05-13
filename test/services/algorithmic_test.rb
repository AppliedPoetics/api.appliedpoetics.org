require "test_helper"

class AlgorithmicTest < ActiveSupport::TestCase
  test "Levenshtein finds pairs within distance 1" do
    result = Levenshtein.create({
      text: "cat bat hat dog",
      distance: 1
    })
    assert_includes result, "cat bat"
    assert_includes result, "cat hat"
    assert_includes result, "bat hat"
    assert_not_includes result.split("\n"), "dog"
  end

  test "Levenshtein finds pairs within distance 2" do
    result = Levenshtein.create({
      text: "cat cut cute",
      distance: 2
    })
    assert_includes result, "cat cut"
    assert_includes result, "cut cute"
    assert_includes result, "cat cute"
  end

  test "Levenshtein ignores duplicate words" do
    result = Levenshtein.create({
      text: "cat cat bat",
      distance: 1
    })
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
    })
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
    })
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
    })
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
    })
    assert_includes result.split, "red"
    assert_includes result.split, "blue"
  end
end
