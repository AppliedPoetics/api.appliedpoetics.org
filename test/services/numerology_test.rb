require "test_helper"

class NumerologyTest < ActiveSupport::TestCase
  test "Nth selects every nth word" do
    result = Nth.create({
      text: "one two three four five six",
      n: 2
    })
    assert_equal "two four six", result[:result]
  end

  test "Nth with n equal to one returns all words" do
    result = Nth.create({
      text: "one two three",
      n: 1
    })
    assert_equal "one two three", result[:result]
  end

  test "Nth with n larger than word count returns empty string" do
    result = Nth.create({
      text: "one two",
      n: 5
    })
    assert_equal "", result[:result]
  end

  test "Nth raises ArgumentError when n is zero" do
    assert_raises(ArgumentError) do
      Nth.create({
        text: "one two three",
        n: 0
      })
    end
  end

  test "Nth raises ArgumentError when n is negative" do
    assert_raises(ArgumentError) do
      Nth.create({
        text: "one two three",
        n: -1
      })
    end
  end

  test "Nth raises KeyError when n is missing" do
    assert_raises(KeyError) do
      Nth.create({
        text: "one two three"
      })
    end
  end

  test "Pithon returns pi to number of decimal places equal to word count" do
    result = Pithon.create({
      text: "hello world"
    })
    assert_equal "3.14", result[:result]
  end

  test "Pithon returns 3 for empty text" do
    result = Pithon.create({
      text: ""
    })
    assert_equal "3", result[:result]
  end

  test "Pithon returns pi with correct decimal places for longer text" do
    result = Pithon.create({
      text: "one two three four five"
    })
    assert_equal "3.14159", result[:result]
  end

  test "Length selects words of given length" do
    result = Length.create({
      text: "The quick brown fox jumps over the lazy dog",
      n: 3
    })
    assert_equal "The fox the dog", result[:result]
  end

  test "Length selects words of length four" do
    result = Length.create({
      text: "The quick brown fox jumps over the lazy dog",
      n: 4
    })
    assert_equal "over lazy", result[:result]
  end

  test "Length returns empty string when no words match" do
    result = Length.create({
      text: "one two three",
      n: 10
    })
    assert_equal "", result[:result]
  end

  test "Length raises ArgumentError when n is zero" do
    assert_raises(ArgumentError) do
      Length.create({
        text: "one two three",
        n: 0
      })
    end
  end

  test "Length raises ArgumentError when n is negative" do
    assert_raises(ArgumentError) do
      Length.create({
        text: "one two three",
        n: -1
      })
    end
  end

  test "Length raises KeyError when n is missing" do
    assert_raises(KeyError) do
      Length.create({
        text: "one two three"
      })
    end
  end

  test "Birthday selects words based on birthdate digits advancing from current position" do
    result = Birthday.create({
      text: "alpha bravo charlie delta echo foxtrot golf hotel india juliet",
      birthdate: "03-14-1985"
    })
    assert_equal "alpha delta echo india juliet india golf bravo bravo echo", result[:result]
  end

  test "Birthday with all ones advances one step each time" do
    result = Birthday.create({
      text: "alpha bravo charlie delta echo foxtrot golf hotel india juliet",
      birthdate: "01-01-2000"
    })
    assert_equal "alpha bravo bravo charlie echo echo echo echo echo foxtrot", result[:result]
  end

  test "Birthday with short text" do
    result = Birthday.create({
      text: "one two three",
      birthdate: "31-12-1999"
    })
    assert_equal "one two three", result[:result]
  end

  test "Birthday returns empty string for empty text" do
    result = Birthday.create({
      text: "",
      birthdate: "03-14-1985"
    })
    assert_equal "", result[:result]
  end

  test "Birthday raises ArgumentError for invalid birthdate format" do
    assert_raises(ArgumentError) do
      Birthday.create({
        text: "one two three",
        birthdate: "1985-03-14"
      })
    end
  end

  test "Birthday raises KeyError when birthdate is missing" do
    assert_raises(KeyError) do
      Birthday.create({
        text: "one two three"
      })
    end
  end

  test "Phonewords selects words containing only letters from phone number digits" do
    result = Phonewords.create({
      text: "bad bed cab fed dad ace face",
      phone: "2223333"
    })
    assert_equal "bad bed cab fed dad ace face", result[:result]
  end

  test "Phonewords excludes words with letters not on given digits" do
    result = Phonewords.create({
      text: "hello world cat dog",
      phone: "2223333"
    })
    assert_equal "", result[:result]
  end

  test "Phonewords with mixed matching and non-matching words" do
    result = Phonewords.create({
      text: "bad hello cab world fed",
      phone: "2223333"
    })
    assert_equal "bad cab fed", result[:result]
  end

  test "Phonewords ignores punctuation when checking letters" do
    result = Phonewords.create({
      text: "bad! cab. fed?",
      phone: "2223333"
    })
    assert_equal "bad! cab. fed?", result[:result]
  end

  test "Phonewords with digits 4 and 7 includes GHI and PQRS" do
    result = Phonewords.create({
      text: "hi sir grip quiz his rip",
      phone: "4447777"
    })
    assert_equal "hi sir grip his rip", result[:result]
  end

  test "Phonewords raises ArgumentError for invalid phone length" do
    assert_raises(ArgumentError) do
      Phonewords.create({
        text: "hello world",
        phone: "12345"
      })
    end
  end

  test "Phonewords raises ArgumentError for non-numeric phone" do
    assert_raises(ArgumentError) do
      Phonewords.create({
        text: "hello world",
        phone: "abc-defg"
      })
    end
  end

  test "Phonewords raises KeyError when phone is missing" do
    assert_raises(KeyError) do
      Phonewords.create({
        text: "hello world"
      })
    end
  end
end
