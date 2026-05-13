require "test_helper"

module V1
  class ApplicationControllerTest < ActionDispatch::IntegrationTest
    test "should process syntax concordance" do
      post v1_path(cat: "syntax", mtd: "concordance"), params: {
        text: "the quick brown fox jumps over the lazy dog",
        word: "fox",
        context: 1
      }
      assert_response :ok
      body = JSON.parse(response.body)
      assert_includes body["result"], "brown fox jumps"
    end

    test "should process syntax alternator" do
      post v1_path(cat: "syntax", mtd: "alternator"), params: {
        text: "banana radar level civic test"
      }
      assert_response :ok
      body = JSON.parse(response.body)
      assert_includes body["result"], "banana"
      assert_includes body["result"], "radar"
      assert_includes body["result"], "level"
      assert_includes body["result"], "civic"
    end

    test "should process grammar punctuator" do
      post v1_path(cat: "grammar", mtd: "punctuator"), params: {
        text: "Hello, world! How are you?"
      }
      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal "     ,      !            ?", body["result"]
    end

    test "should process oulipean lipogram" do
      post v1_path(cat: "oulipean", mtd: "lipogram"), params: {
        text: "the quick brown fox",
        letters: "e"
      }
      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal "quick brown fox", body["result"]
    end

    test "should return bad request when parameters are missing" do
      post v1_path(cat: "syntax", mtd: "concordance"), params: {
        text: "hello world"
        # missing :word and :context
      }
      assert_response :bad_request
    end

    test "should return bad request for missing category parameters" do
      post v1_path(cat: "syntax", mtd: "concordance"), params: {}
      assert_response :bad_request
    end

    test "should process numerology pithon" do
      post v1_path(cat: "numerology", mtd: "pithon"), params: {
        text: "hello world"
      }
      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal "3.14", body["result"]
    end

    test "should process numerology length" do
      post v1_path(cat: "numerology", mtd: "length"), params: {
        text: "The quick brown fox jumps over the lazy dog",
        n: 3
      }
      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal "The fox the dog", body["result"]
    end

    test "should process numerology birthday" do
      post v1_path(cat: "numerology", mtd: "birthday"), params: {
        text: "alpha bravo charlie delta echo foxtrot golf hotel india juliet",
        birthdate: "03-14-1985"
      }
      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal "alpha delta echo india juliet india golf bravo bravo echo", body["result"]
    end

    test "should process numerology phonewords" do
      post v1_path(cat: "numerology", mtd: "phonewords"), params: {
        text: "bad bed cab fed dad ace face",
        phone: "2223333"
      }
      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal "bad bed cab fed dad ace face", body["result"]
    end

    test "should return bad request for numerology with missing params" do
      post v1_path(cat: "numerology", mtd: "length"), params: {
        text: "hello world"
        # missing :n
      }
      assert_response :bad_request
    end

    test "should process pop powerball" do
      def Powerball.fetch_numbers; [ 1, 2 ]; end
      post v1_path(cat: "pop", mtd: "powerball"), params: {
        text: "one two three four five"
      }
      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal "two four five two three", body["result"]
    end

    test "should process pop weatherizer" do
      post v1_path(cat: "pop", mtd: "weatherizer"), params: {
        text: "The sun is shining. I walked to the store. A storm is coming."
      }
      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal "The sun is shining. A storm is coming.", body["result"]
    end

    test "should process pop colorizer" do
      post v1_path(cat: "pop", mtd: "colorizer"), params: {
        text: "The sky was blue. I walked to the store. The leaves turned crimson."
      }
      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal "The sky was blue. The leaves turned crimson.", body["result"]
    end

    test "should process pop sartorializer" do
      post v1_path(cat: "pop", mtd: "sartorializer"), params: {
        text: "She wore a beautiful silk dress. The weather was nice. He had on leather boots."
      }
      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal "She wore a beautiful silk dress. He had on leather boots.", body["result"]
    end
  end
end
