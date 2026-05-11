require "test_helper"

class SyntaxTest < ActiveSupport::TestCase
  test "Concordance finds word with context" do
    result = Concordance.create({
      text: "the quick brown fox jumps over the lazy dog",
      word: "fox",
      context: 1
    })
    assert_equal "brown fox jumps\n", result
  end

  test "Abecedarian selects words in alphabetical order" do
    result = Abecedarian.create({
      text: "apple banana apricot blueberry cherry"
    })
    assert_equal "apple banana cherry", result
  end

  test "Abcquence selects words with sorted letters" do
    result = Abcquence.create({
      text: "billowy beefy chimp dusty"
    })
    assert_equal "billowy beefy chimp", result
  end

  test "ChainReaction links words by last and first letters" do
    result = ChainReaction.create({
      text: "apple elephant tiger rose"
    })
    assert_equal "apple elephant tiger rose", result
  end

  test "Anagram replaces words with anagrams when available" do
    result = Anagram.create({
      text: "listen"
    })
    assert_not_equal "listen", result
    assert_equal result.downcase.chars.sort, "listen".chars.sort
  end

  test "Alternator finds vowel-consonant alternating words" do
    result = Alternator.create({
      text: "banana radar level civic test book"
    })
    assert_includes result, "banana"
    assert_includes result, "radar"
    assert_includes result, "level"
    assert_includes result, "civic"
    assert_not_includes result.split, "test"
    assert_not_includes result.split, "book"
  end

  test "Hexwords translates words into hex-style spellings" do
    result = Hexwords.create({
      text: "coffee dead beef cafe fox test bad good hello"
    })
    assert_includes result, "c0ff33"
    assert_includes result, "dead"
    assert_includes result, "beef"
    assert_includes result, "cafe"
    assert_includes result, "7357"
    assert_includes result, "bad"
    assert_includes result, "600d"
    assert_not_includes result.split, "fox"
    assert_not_includes result.split, "hello"
  end
end
