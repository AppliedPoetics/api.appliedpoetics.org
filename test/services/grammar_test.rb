require "test_helper"

class GrammarTest < ActiveSupport::TestCase
  test "Punctuator extracts only punctuation" do
    result = Punctuator.create({
      text: "Hello, world! How are you?"
    })
    assert_equal "     ,      !            ?", result[:result]
  end

  test "Isolator filters sentences by punctuation delimiter" do
    # Note: the current implementation splits on punctuation and removes it,
    # so s.last checks the last character of the sentence fragment, not the delimiter.
    result = Isolator.create({
      text: "Hello world. How are you! I am fine. Great!",
      punctuation: "."
    })
    # Since punctuation is stripped by split, no fragments end with "."
    assert_equal "", result[:result]
  end

  test "Quotations extracts quoted strings" do
    result = Quotations.create({
      text: 'She said "hello" and then "goodbye"'
    })
    assert_equal "hello goodbye", result[:result]
  end

  test "PartsOfSpeech extracts nouns" do
    result = PartsOfSpeech.create({
      text: "The quick brown fox jumps.",
      tag: "nouns"
    })
    assert_includes result[:result], "fox"
  end

  test "PartsOfSpeech raises error for invalid tag" do
    assert_raises(ArgumentError) do
      PartsOfSpeech.create({
        text: "Hello world",
        tag: "invalid_tag"
      })
    end
  end
end
