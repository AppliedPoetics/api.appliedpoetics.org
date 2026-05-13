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

  test "Weatherizer selects sentences containing weather terms" do
    result = Weatherizer.create({
      text: "The sun is shining. I walked to the store. A storm is coming."
    })
    assert_equal "The sun is shining. A storm is coming.", result[:result]
  end

  test "Weatherizer is case insensitive" do
    result = Weatherizer.create({
      text: "The SUN was hot. The dog barked. It started to RAIN."
    })
    assert_equal "The SUN was hot. It started to RAIN.", result[:result]
  end

  test "Weatherizer returns empty string when no weather terms found" do
    result = Weatherizer.create({
      text: "The cat sat on the mat. I went to the market."
    })
    assert_equal "", result[:result]
  end

  test "Weatherizer returns empty string for empty text" do
    result = Weatherizer.create({
      text: ""
    })
    assert_equal "", result[:result]
  end

  test "Weatherizer handles multiple weather terms in one sentence" do
    result = Weatherizer.create({
      text: "The cold wind and rain made the day miserable. I stayed inside. The sun came out later."
    })
    assert_equal "The cold wind and rain made the day miserable. The sun came out later.", result[:result]
  end

  test "Colorizer selects sentences containing color names" do
    result = Colorizer.create({
      text: "The sky was blue. I walked to the store. The leaves turned crimson."
    })
    assert_equal "The sky was blue. The leaves turned crimson.", result[:result]
  end

  test "Colorizer is case insensitive" do
    result = Colorizer.create({
      text: "She wore a BLUE dress. The cat was black. He chose AZURE paint."
    })
    assert_equal "She wore a BLUE dress. The cat was black. He chose AZURE paint.", result[:result]
  end

  test "Colorizer returns empty string when no color names found" do
    result = Colorizer.create({
      text: "The dog ran fast. I went to the market."
    })
    assert_equal "", result[:result]
  end

  test "Colorizer returns empty string for empty text" do
    result = Colorizer.create({
      text: ""
    })
    assert_equal "", result[:result]
  end

  test "Colorizer handles multiple color names in one sentence" do
    result = Colorizer.create({
      text: "The red and blue flag waved. It was a sunny day. The green grass grew."
    })
    assert_equal "The red and blue flag waved. The green grass grew.", result[:result]
  end

  test "Sartorializer selects sentences containing fashion terms" do
    result = Sartorializer.create({
      text: "She wore a beautiful silk dress. The weather was nice. He had on leather boots."
    })
    assert_equal "She wore a beautiful silk dress. He had on leather boots.", result[:result]
  end

  test "Sartorializer is case insensitive" do
    result = Sartorializer.create({
      text: "She bought a BLAZER. The cat slept. He adjusted his TIE."
    })
    assert_equal "She bought a BLAZER. He adjusted his TIE.", result[:result]
  end

  test "Sartorializer returns empty string when no fashion terms found" do
    result = Sartorializer.create({
      text: "The dog ran fast. I went to the market."
    })
    assert_equal "", result[:result]
  end

  test "Sartorializer returns empty string for empty text" do
    result = Sartorializer.create({
      text: ""
    })
    assert_equal "", result[:result]
  end

  test "Sartorializer handles multiple fashion terms in one sentence" do
    result = Sartorializer.create({
      text: "Her velvet scarf and wool coat were stunning. It was cold outside. His denim jeans fit well."
    })
    assert_equal "Her velvet scarf and wool coat were stunning. His denim jeans fit well.", result[:result]
  end
end
