require "test_helper"

class FormicTest < ActiveSupport::TestCase
  test "Sestina generates six stanzas and an envoi from six end-words" do
    result = Sestina.create({
      text: "one two three four five six"
    })

    stanzas = result.split("\n\n")
    assert_equal 7, stanzas.length, "Expected 6 stanzas + 1 envoi"

    # First stanza preserves original order
    assert_equal "one\ntwo\nthree\nfour\nfive\nsix", stanzas[0]

    # Second stanza follows sestina pattern: 6,1,5,2,4,3
    assert_equal "six\none\nfive\ntwo\nfour\nthree", stanzas[1]

    # Envoi is a tercet with paired end-words
    envoi_lines = stanzas[6].split("\n")
    assert_equal 3, envoi_lines.length
    assert_equal "two five", envoi_lines[0]
    assert_equal "four three", envoi_lines[1]
    assert_equal "six one", envoi_lines[2]
  end

  test "Sestina extracts end-words from last word of each line when six lines provided" do
    result = Sestina.create({
      text: "The house stood silent\nThe garden overgrown\nThe door unlocked\nThe windows dark\nThe hearth cold\nThe memories linger"
    })

    stanzas = result.split("\n\n")
    assert_equal 7, stanzas.length

    # First stanza end-words should be the last word of each line
    assert_equal "silent\novergrown\nunlocked\ndark\ncold\nlinger", stanzas[0]
  end

  test "Sestina raises ArgumentError when fewer than six end-words are provided" do
    assert_raises(ArgumentError) do
      Sestina.create({
        text: "one two three"
      })
    end
  end

  test "Sestina raises ArgumentError when text is empty" do
    assert_raises(ArgumentError) do
      Sestina.create({
        text: ""
      })
    end
  end

  test "Sestina raises ArgumentError when text is nil" do
    assert_raises(ArgumentError) do
      Sestina.create({
        text: nil
      })
    end
  end

  test "Formic dispatch creates Sestina via string name" do
    result = Formic.create("sestina", {
      text: "alpha beta gamma delta epsilon zeta"
    })

    stanzas = result.split("\n\n")
    assert_equal 7, stanzas.length
    assert_equal "alpha\nbeta\ngamma\ndelta\nepsilon\nzeta", stanzas[0]
  end

  test "Triolet generates eight lines from five input lines" do
    result = Triolet.create({
      text: "Line one\nLine two\nLine three\nLine four\nLine five"
    })

    lines = result.split("\n")
    assert_equal 8, lines.length
    assert_equal "Line one", lines[0]
    assert_equal "Line two", lines[1]
    assert_equal "Line three", lines[2]
    assert_equal "Line one", lines[3]
    assert_equal "Line four", lines[4]
    assert_equal "Line five", lines[5]
    assert_equal "Line one", lines[6]
    assert_equal "Line two", lines[7]
  end

  test "Triolet uses first five lines when more are provided" do
    result = Triolet.create({
      text: "A\nB\nC\nD\nE\nF\nG"
    })

    lines = result.split("\n")
    assert_equal 8, lines.length
    assert_equal "A", lines[0]
    assert_equal "B", lines[1]
    assert_equal "C", lines[2]
    assert_equal "A", lines[3]
    assert_equal "D", lines[4]
    assert_equal "E", lines[5]
    assert_equal "A", lines[6]
    assert_equal "B", lines[7]
  end

  test "Triolet raises ArgumentError when fewer than five lines are provided" do
    assert_raises(ArgumentError) do
      Triolet.create({
        text: "Line one\nLine two\nLine three"
      })
    end
  end

  test "Triolet raises ArgumentError when text is empty" do
    assert_raises(ArgumentError) do
      Triolet.create({
        text: ""
      })
    end
  end

  test "Triolet raises ArgumentError when text is nil" do
    assert_raises(ArgumentError) do
      Triolet.create({
        text: nil
      })
    end
  end

  test "Formic dispatch creates Triolet via string name" do
    result = Formic.create("triolet", {
      text: "A\nB\nC\nD\nE"
    })

    lines = result.split("\n")
    assert_equal 8, lines.length
    assert_equal "A", lines[0]
    assert_equal "B", lines[1]
    assert_equal "C", lines[2]
    assert_equal "A", lines[3]
    assert_equal "D", lines[4]
    assert_equal "E", lines[5]
    assert_equal "A", lines[6]
    assert_equal "B", lines[7]
  end

  test "Pantoum generates repeating quatrains from eight lines" do
    result = Pantoum.create({
      text: "A\nB\nC\nD\nE\nF\nG\nH"
    })

    stanzas = result.split("\n\n")
    assert_equal 4, stanzas.length

    assert_equal "A\nB\nC\nD", stanzas[0]
    assert_equal "B\nE\nD\nF", stanzas[1]
    assert_equal "E\nG\nF\nH", stanzas[2]
    assert_equal "G\nA\nH\nC", stanzas[3]
  end

  test "Pantoum generates three stanzas from six lines" do
    result = Pantoum.create({
      text: "A\nB\nC\nD\nE\nF"
    })

    stanzas = result.split("\n\n")
    assert_equal 3, stanzas.length

    assert_equal "A\nB\nC\nD", stanzas[0]
    assert_equal "B\nE\nD\nF", stanzas[1]
    assert_equal "E\nA\nF\nC", stanzas[2]
  end

  test "Pantoum generates two stanzas from four lines" do
    result = Pantoum.create({
      text: "A\nB\nC\nD"
    })

    stanzas = result.split("\n\n")
    assert_equal 2, stanzas.length

    assert_equal "A\nB\nC\nD", stanzas[0]
    assert_equal "B\nA\nD\nC", stanzas[1]
  end

  test "Pantoum raises ArgumentError when fewer than four lines are provided" do
    assert_raises(ArgumentError) do
      Pantoum.create({
        text: "A\nB\nC"
      })
    end
  end

  test "Pantoum raises ArgumentError when odd number of lines are provided" do
    assert_raises(ArgumentError) do
      Pantoum.create({
        text: "A\nB\nC\nD\nE"
      })
    end
  end

  test "Pantoum raises ArgumentError when text is empty" do
    assert_raises(ArgumentError) do
      Pantoum.create({
        text: ""
      })
    end
  end

  test "Pantoum raises ArgumentError when text is nil" do
    assert_raises(ArgumentError) do
      Pantoum.create({
        text: nil
      })
    end
  end

  test "Formic dispatch creates Pantoum via string name" do
    result = Formic.create("pantoum", {
      text: "A\nB\nC\nD\nE\nF\nG\nH"
    })

    stanzas = result.split("\n\n")
    assert_equal 4, stanzas.length
    assert_equal "A\nB\nC\nD", stanzas[0]
    assert_equal "B\nE\nD\nF", stanzas[1]
  end
end
