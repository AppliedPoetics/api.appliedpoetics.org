require "test_helper"

class FormicTest < ActiveSupport::TestCase
  setup do
    @text = File.read(Rails.root.join("data", "test.txt"))
  end

  test "Sestina generates six stanzas and an envoi from test.txt" do
    result = Sestina.create({ text: @text })
    assert_kind_of Hash, result
    stanzas = result[:result].split("\n\n")
    assert_equal 7, stanzas.length, "Expected 6 stanzas + 1 envoi"

    # First stanza preserves the six end-words in order
    first_stanza_lines = stanzas[0].split("\n")
    assert_equal 6, first_stanza_lines.length
    assert_equal "reflections.", first_stanza_lines[0]
    assert_equal "back.",          first_stanza_lines[1]
    assert_equal "them.",          first_stanza_lines[2]
    assert_equal "photograph.",    first_stanza_lines[3]
    assert_equal "bank.\"",        first_stanza_lines[4]
    assert_equal "eyes.",          first_stanza_lines[5]

    # Second stanza follows sestina pattern: 6,1,5,2,4,3
    second_stanza_lines = stanzas[1].split("\n")
    assert_equal "eyes.",          second_stanza_lines[0]
    assert_equal "reflections.",   second_stanza_lines[1]
    assert_equal "bank.\"",        second_stanza_lines[2]
    assert_equal "back.",          second_stanza_lines[3]
    assert_equal "photograph.",    second_stanza_lines[4]
    assert_equal "them.",          second_stanza_lines[5]

    # Envoi is a tercet with paired end-words
    envoi_lines = stanzas[6].split("\n")
    assert_equal 3, envoi_lines.length
    assert_equal "back. bank.\"",       envoi_lines[0]
    assert_equal "photograph. them.",  envoi_lines[1]
    assert_equal "eyes. reflections.", envoi_lines[2]
  end

  test "Sestina raises ArgumentError when fewer than six end-words are provided" do
    assert_raises(ArgumentError) do
      Sestina.create({ text: "one two three" })
    end
  end

  test "Sestina raises ArgumentError when text is empty" do
    assert_raises(ArgumentError) do
      Sestina.create({ text: "" })
    end
  end

  test "Sestina raises ArgumentError when text is nil" do
    assert_raises(ArgumentError) do
      Sestina.create({ text: nil })
    end
  end

  test "Formic dispatch creates Sestina via string name" do
    result = Formic.create("sestina", { text: @text })
    assert_kind_of Hash, result
    assert result[:result].include?("reflections.")
  end

  test "Triolet generates eight lines from test.txt" do
    result = Triolet.create({ text: @text })
    assert_kind_of Hash, result
    lines = result[:result].split("\n")
    assert_equal 8, lines.length

    # Pattern: [0, 1, 2, 0, 3, 4, 0, 1]
    assert_equal lines[0], lines[3]
    assert_equal lines[0], lines[6]
    assert_equal lines[1], lines[7]
  end

  test "Triolet raises ArgumentError when fewer than five lines are provided" do
    assert_raises(ArgumentError) do
      Triolet.create({ text: "Line one\nLine two\nLine three" })
    end
  end

  test "Triolet raises ArgumentError when text is empty" do
    assert_raises(ArgumentError) do
      Triolet.create({ text: "" })
    end
  end

  test "Triolet raises ArgumentError when text is nil" do
    assert_raises(ArgumentError) do
      Triolet.create({ text: nil })
    end
  end

  test "Formic dispatch creates Triolet via string name" do
    result = Formic.create("triolet", { text: @text })
    assert_kind_of Hash, result
    lines = result[:result].split("\n")
    assert_equal 8, lines.length
  end

  test "Pantoum generates repeating quatrains from test.txt" do
    result = Pantoum.create({ text: @text })
    assert_kind_of Hash, result
    stanzas = result[:result].split("\n\n")
    assert_equal 8, stanzas.length

    # Each stanza should have 4 lines
    stanzas.each do |stanza|
      assert_equal 4, stanza.split("\n").length
    end
  end

  test "Pantoum raises ArgumentError when fewer than four lines are provided" do
    assert_raises(ArgumentError) do
      Pantoum.create({ text: "A\nB\nC" })
    end
  end

  test "Pantoum raises ArgumentError when odd number of lines are provided" do
    assert_raises(ArgumentError) do
      Pantoum.create({ text: "A\nB\nC\nD\nE" })
    end
  end

  test "Pantoum raises ArgumentError when text is empty" do
    assert_raises(ArgumentError) do
      Pantoum.create({ text: "" })
    end
  end

  test "Pantoum raises ArgumentError when text is nil" do
    assert_raises(ArgumentError) do
      Pantoum.create({ text: nil })
    end
  end

  test "Formic dispatch creates Pantoum via string name" do
    result = Formic.create("pantoum", { text: @text })
    assert_kind_of Hash, result
    stanzas = result[:result].split("\n\n")
    assert_equal 8, stanzas.length
  end

  test "Pattern extract returns words by default" do
    engine = Formic.const_get(:PatternEngine)
    words = engine.send(:extract, "one two three")
    assert_equal ["one", "two", "three"], words
  end

  test "Pattern extract returns lines when mode is lines" do
    engine = Formic.const_get(:PatternEngine)
    lines = engine.send(:extract, "a\nb\nc", mode: :lines)
    assert_equal ["a", "b", "c"], lines
  end

  test "Pattern extract returns end words when mode is end_words" do
    engine = Formic.const_get(:PatternEngine)
    words = engine.send(:extract, "a b\nc d\ne f\ng h\ni j\nk l", mode: :end_words)
    assert_equal ["b", "d", "f", "h", "j", "l"], words
  end

  test "Pattern extract falls back to first words when fewer than six lines" do
    engine = Formic.const_get(:PatternEngine)
    words = engine.send(:extract, "one two three four five six", mode: :end_words)
    assert_equal ["one", "two", "three", "four", "five", "six"], words
  end
end
