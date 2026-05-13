require "test_helper"

class OulipeanTest < ActiveSupport::TestCase
  setup do
    @text = File.read(Rails.root.join("data", "test.txt"))
  end

  test "Lipogram excludes words containing given letters" do
    result = Lipogram.create({
      text: @text,
      letters: "e"
    })
    words = result[:result].split
    assert_not_includes words, "Gerald"   # contains 'e'
    assert_includes words, "duck"          # no 'e'
    assert_includes words, "was"           # no 'e'
    assert_includes words, "brown"         # no 'e'
  end

  test "Tautogram includes only words containing given letters" do
    result = Tautogram.create({
      text: @text,
      letters: "e"
    })
    words = result[:result].split
    assert_includes words, "Gerald"        # contains 'e'
    assert_includes words, "reflections."  # contains 'e'
    assert_not_includes words, "duck"      # no 'e'
    assert_not_includes words, "was"       # no 'e'
  end

  test "Homoconsonantism excludes words with vowels" do
    result = Homoconsonantism.create({
      text: @text
    })
    words = result[:result].split
    assert_includes words, "by"
    assert_includes words, "sky"
    assert_not_includes words, "Gerald"
    assert_not_includes words, "duck"
  end

  test "Fibonacci selects words at fibonacci positions" do
    result = Fibonacci.create({
      text: @text
    })
    words = result[:result].split
    assert_equal "Gerald", words[0]
    assert_equal "Gerald", words[1]
    assert_equal "was", words[2]
    assert_equal "a", words[3]
    assert_equal "kind", words[4]
  end

  test "Prisoner excludes words with exiled characters" do
    result = Prisoner.create({
      text: @text
    })
    words = result[:result].split
    assert_includes words, "was"           # no exiled chars
    assert_includes words, "an"            # no exiled chars
    assert_not_includes words, "duck"      # contains 'k'
    assert_not_includes words, "quick"     # contains 'k'
  end

  test "BelleAbsente excludes words containing any of the given letters" do
    result = BelleAbsente.create({
      text: @text,
      letters: "aeiou"
    })
    words = result[:result].split
    assert_includes words, "by"
    assert_includes words, "sky"
    assert_not_includes words, "Gerald"
    assert_not_includes words, "duck"
    assert_not_includes words, "was"
  end

  test "BeauPresente includes only words composed exclusively of given letters" do
    result = BeauPresente.create({
      text: @text,
      letters: "abc"
    })
    words = result[:result].split
    assert_equal ["a", "a", "A", "a", "a", "a", "a", "a"], words
  end

  test "Univocalism removes words containing unwanted vowels" do
    result = Univocalism.create({
      text: @text,
      letters: "a"
    })
    words = result[:result].split
    assert_not_includes words, "Gerald"    # contains 'a'
    assert_not_includes words, "was"       # contains 'a'
    assert_includes words, "the"           # no 'a'
    assert_includes words, "in"            # no 'a'
  end

  test "Snowball sorts words ascending by length with punctuation removed and character count suffix" do
    result = Snowball.create({
      text: @text,
      order: "asc"
    })
    lines = result[:result].split("\n")
    assert_equal "a [1]", lines[0]
    assert lines[-1].start_with?("mirrorperfect")
    assert lines[-1].end_with?("[13]")
  end

  test "Snowball sorts words descending by length with punctuation removed and character count suffix" do
    result = Snowball.create({
      text: @text,
      order: "desc"
    })
    lines = result[:result].split("\n")
    assert lines[0].start_with?("mirrorperfect")
    assert lines[0].end_with?("[13]")
    assert_equal "a [1]", lines[-1]
  end
end
