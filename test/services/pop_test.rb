require "test_helper"

class PopTest < ActiveSupport::TestCase
  test "Powerball selects words using lottery numbers advancing from current position" do
    def Powerball.fetch_numbers; [ 3, 14, 19, 85 ]; end
    result = Powerball.create({
      text: "alpha bravo charlie delta echo foxtrot golf hotel india juliet"
    })
    assert_equal "delta hotel golf bravo echo india hotel charlie foxtrot juliet", result[:result]
  end

  test "Powerball cycles through numbers until text ends" do
    def Powerball.fetch_numbers; [ 1, 2 ]; end
    result = Powerball.create({
      text: "one two three four five"
    })
    assert_equal "two four five two three", result[:result]
  end

  test "Powerball returns empty string for empty text" do
    def Powerball.fetch_numbers; [ 1, 2, 3 ]; end
    result = Powerball.create({
      text: ""
    })
    assert_equal "", result[:result]
  end

  test "Powerball handles single word text" do
    def Powerball.fetch_numbers; [ 5, 10 ]; end
    result = Powerball.create({
      text: "lonely"
    })
    assert_equal "lonely", result[:result]
  end
end
