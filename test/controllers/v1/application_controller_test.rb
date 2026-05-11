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
      assert_includes response.body, "brown fox jumps"
    end

    test "should process syntax alternator" do
      post v1_path(cat: "syntax", mtd: "alternator"), params: {
        text: "banana radar level civic test"
      }
      assert_response :ok
      assert_includes response.body, "banana"
      assert_includes response.body, "radar"
      assert_includes response.body, "level"
      assert_includes response.body, "civic"
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
  end
end
