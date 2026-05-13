require "test_helper"

module V1
  class McpControllerTest < ActionDispatch::IntegrationTest
    test "mcp initialize returns server info" do
      post v1_mcp_path, params: {
        jsonrpc: "2.0",
        id: 1,
        method: "initialize",
        params: {}
      }.to_json, headers: { "CONTENT_TYPE" => "application/json" }

      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal "2.0", body["jsonrpc"]
      assert_equal 1, body["id"]
      assert_equal "applied-poetics-mcp", body["result"]["serverInfo"]["name"]
      assert_equal "2024-11-05", body["result"]["protocolVersion"]
    end

    test "mcp tools/list returns available tools" do
      post v1_mcp_path, params: {
        jsonrpc: "2.0",
        id: 2,
        method: "tools/list",
        params: {}
      }.to_json, headers: { "CONTENT_TYPE" => "application/json" }

      assert_response :ok
      body = JSON.parse(response.body)
      tools = body["result"]["tools"]
      assert tools.is_a?(Array)
      assert tools.length > 0

      tool_names = tools.map { |t| t["name"] }
      assert_includes tool_names, "syntax_concordance"
      assert_includes tool_names, "numerology_pithon"
      assert_includes tool_names, "pop_powerball"
      assert_includes tool_names, "pop_weatherizer"
      assert_includes tool_names, "pop_colorizer"
      assert_includes tool_names, "pop_sartorializer"
    end

    test "mcp tools/call invokes a tool" do
      post v1_mcp_path, params: {
        jsonrpc: "2.0",
        id: 3,
        method: "tools/call",
        params: {
          name: "numerology_pithon",
          arguments: { text: "hello world" }
        }
      }.to_json, headers: { "CONTENT_TYPE" => "application/json" }

      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal "2.0", body["jsonrpc"]
      assert_equal 3, body["id"]
      assert_equal "3.14", body["result"]["content"].first["text"]
      assert_equal false, body["result"]["isError"]
    end

    test "mcp tools/call with missing params returns error" do
      post v1_mcp_path, params: {
        jsonrpc: "2.0",
        id: 4,
        method: "tools/call",
        params: {
          name: "numerology_length",
          arguments: { text: "hello world" }
        }
      }.to_json, headers: { "CONTENT_TYPE" => "application/json" }

      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal true, body["result"]["isError"]
      assert_includes body["result"]["content"].first["text"], "n"
    end

    test "mcp resources/list returns data files" do
      post v1_mcp_path, params: {
        jsonrpc: "2.0",
        id: 5,
        method: "resources/list",
        params: {}
      }.to_json, headers: { "CONTENT_TYPE" => "application/json" }

      assert_response :ok
      body = JSON.parse(response.body)
      resources = body["result"]["resources"]
      assert resources.is_a?(Array)

      uris = resources.map { |r| r["uri"] }
      assert_includes uris, "data://colors.txt"
      assert_includes uris, "data://weather_terms.txt"
      assert_includes uris, "data://fashion_terms.txt"
    end

    test "mcp resources/read returns file contents" do
      post v1_mcp_path, params: {
        jsonrpc: "2.0",
        id: 6,
        method: "resources/read",
        params: { uri: "data://colors.txt" }
      }.to_json, headers: { "CONTENT_TYPE" => "application/json" }

      assert_response :ok
      body = JSON.parse(response.body)
      contents = body["result"]["contents"]
      assert contents.is_a?(Array)
      assert contents.first["text"].include?("aliceblue")
    end

    test "mcp resources/read returns error for missing resource" do
      post v1_mcp_path, params: {
        jsonrpc: "2.0",
        id: 7,
        method: "resources/read",
        params: { uri: "data://nonexistent.txt" }
      }.to_json, headers: { "CONTENT_TYPE" => "application/json" }

      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal -32602, body["error"]["code"]
    end

    test "mcp unknown method returns error" do
      post v1_mcp_path, params: {
        jsonrpc: "2.0",
        id: 8,
        method: "unknown/method",
        params: {}
      }.to_json, headers: { "CONTENT_TYPE" => "application/json" }

      assert_response :ok
      body = JSON.parse(response.body)
      assert_equal -32601, body["error"]["code"]
    end

    test "mcp invalid json returns parse error" do
      post v1_mcp_path, params: "not json", headers: { "CONTENT_TYPE" => "application/json" }
      assert_response :bad_request
      body = JSON.parse(response.body)
      assert_equal -32700, body["error"]["code"]
    end
  end
end
