require "test_helper"

class OperationTest < ActiveSupport::TestCase
  def with_net_http_stub(return_value)
    original = Net::HTTP.method(:get)
    Net::HTTP.define_singleton_method(:get) do |uri|
      return_value.respond_to?(:call) ? return_value.call(uri) : return_value
    end
    yield
  ensure
    Net::HTTP.define_singleton_method(:get, original)
  end

  # Gutenberg tests

  test "Gutenberg strips preamble and postamble" do
    body = <<~TEXT
      Some header text here
      *** START OF THE PROJECT GUTENBERG EBOOK THE TEST BOOK ***
      The real content.
      It spans multiple lines.
      *** END OF THE PROJECT GUTENBERG EBOOK THE TEST BOOK ***
      Some footer text here
    TEXT

    with_net_http_stub(body) do
      result = Gutenberg.create({ url: "https://example.com/test.txt" })
      assert_equal "The real content.\nIt spans multiple lines.", result[:result]
    end
  end

  test "Gutenberg strips only start marker when end marker is missing" do
    body = <<~TEXT
      Header
      *** START OF THIS PROJECT GUTENBERG EBOOK THE TEST BOOK ***
      Content only.
    TEXT

    with_net_http_stub(body) do
      result = Gutenberg.create({ url: "https://example.com/test.txt" })
      assert_equal "Content only.", result[:result]
    end
  end

  test "Gutenberg strips only end marker when start marker is missing" do
    body = <<~TEXT
      Content only.
      *** END OF THE PROJECT GUTENBERG EBOOK THE TEST BOOK ***
      Footer
    TEXT

    with_net_http_stub(body) do
      result = Gutenberg.create({ url: "https://example.com/test.txt" })
      assert_equal "Content only.", result[:result]
    end
  end

  test "Gutenberg returns whole body when no markers found" do
    body = "Plain text without any Gutenberg markers."
    with_net_http_stub(body) do
      result = Gutenberg.create({ url: "https://example.com/test.txt" })
      assert_equal "Plain text without any Gutenberg markers.", result[:result]
    end
  end

  test "Gutenberg raises KeyError when url is missing" do
    assert_raises(KeyError) do
      Gutenberg.create({})
    end
  end

  test "Gutenberg raises on network error" do
    with_net_http_stub(->(_uri) { raise SocketError, "Failed to open TCP" }) do
      error = assert_raises(RuntimeError) do
        Gutenberg.create({ url: "https://example.com/test.txt" })
      end
      assert_match "Failed to download Gutenberg text", error.message
    end
  end

  # Wikipedia tests

  test "Wikipedia returns extract for valid title" do
    response = {
      "query" => {
        "pages" => {
          "12345" => {
            "pageid" => 12345,
            "title" => "Ruby (programming language)",
            "extract" => "Ruby is a dynamic, open source programming language."
          }
        }
      }
    }.to_json

    with_net_http_stub(response) do
      result = Wikipedia.create({ title: "Ruby (programming language)" })
      assert_equal "Ruby is a dynamic, open source programming language.", result[:result]
    end
  end

  test "Wikipedia raises when page is missing" do
    response = {
      "query" => {
        "pages" => {
          "-1" => {
            "ns" => 0,
            "title" => "NonExistentPageXYZ123",
            "missing" => true
          }
        }
      }
    }.to_json

    with_net_http_stub(response) do
      error = assert_raises(RuntimeError) do
        Wikipedia.create({ title: "NonExistentPageXYZ123" })
      end
      assert_match "Page not found", error.message
    end
  end

  test "Wikipedia raises when no extract is available" do
    response = {
      "query" => {
        "pages" => {
          "12345" => {
            "pageid" => 12345,
            "title" => "SomePage"
          }
        }
      }
    }.to_json

    with_net_http_stub(response) do
      error = assert_raises(RuntimeError) do
        Wikipedia.create({ title: "SomePage" })
      end
      assert_match "No extract available", error.message
    end
  end

  test "Wikipedia raises when query is missing" do
    response = {}.to_json
    with_net_http_stub(response) do
      error = assert_raises(RuntimeError) do
        Wikipedia.create({ title: "AnyPage" })
      end
      assert_match "No pages found", error.message
    end
  end

  test "Wikipedia raises KeyError when title is missing" do
    assert_raises(KeyError) do
      Wikipedia.create({})
    end
  end

  test "Wikipedia raises on network error" do
    with_net_http_stub(->(_uri) { raise SocketError, "Failed to open TCP" }) do
      error = assert_raises(RuntimeError) do
        Wikipedia.create({ title: "Ruby" })
      end
      assert_match "Failed to connect to Wikipedia API", error.message
    end
  end

  test "Wikipedia raises on invalid JSON response" do
    with_net_http_stub("not json") do
      error = assert_raises(RuntimeError) do
        Wikipedia.create({ title: "Ruby" })
      end
      assert_match "Invalid response from Wikipedia API", error.message
    end
  end
end
