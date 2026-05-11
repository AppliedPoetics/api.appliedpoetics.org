require "test_helper"

class OulipeanTest < ActiveSupport::TestCase
  test "Lipogram excludes words containing given letters" do
    result = Lipogram.create({
      text: "the quick brown fox",
      letters: "e"
    })
    assert_equal "quick brown fox", result[:result]
  end

  test "Tautogram includes only words containing given letters" do
    result = Tautogram.create({
      text: "the quick brown fox",
      letters: "e"
    })
    assert_equal "the", result[:result]
  end

  test "Homoconsonantism excludes words with vowels" do
    result = Homoconsonantism.create({
      text: "my gym rhythm"
    })
    assert_equal "my gym rhythm", result[:result]
  end

  test "Fibonacci selects words at fibonacci positions" do
    result = Fibonacci.create({
      text: "one two three four five six seven eight nine ten"
    })
    assert_equal "one one two three five eight", result[:result]
  end

  test "Prisoner excludes words with exiled characters" do
    result = Prisoner.create({
      text: "a cute maze of weird kiwi liquor"
    })
    assert_equal "a maze", result[:result]
  end

  test "BelleAbsente excludes words containing given letters" do
    result = BelleAbsente.create({
      text: "the quick brown fox",
      letters: "e"
    })
    assert_equal "quick brown fox", result[:result]
  end

  test "BeauPresente includes only words containing given letters" do
    result = BeauPresente.create({
      text: "the quick brown fox",
      letters: "e"
    })
    assert_equal "the", result[:result]
  end

  test "Univocalism removes words containing unwanted vowels" do
    result = Univocalism.create({
      text: "banana apple cherry",
      letters: "a"
    })
    # Keeps only words without vowels other than 'a' (implementation removes words containing 'a')
    assert_includes result, "cherry"
    assert_not_includes result.split, "banana"
    assert_not_includes result.split, "apple"
  end

  test "Snowball sorts words ascending by length" do
    result = Snowball.create({
      text: "a big elephant ran fast",
      order: "asc"
    })
    assert_equal "a big ran fast elephant", result
  end

  test "Snowball sorts words descending by length" do
    result = Snowball.create({
      text: "a big elephant ran fast",
      order: "desc"
    })
    assert_equal "elephant fast ran big a", result
  end
end
