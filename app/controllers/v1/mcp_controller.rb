module V1
    class McpController < ActionController::API
        def create
            req = JSON.parse(request.body.read)
            response = route_mcp_request(req)
            render json: response
        rescue JSON::ParserError
            render json: error_response(nil, -32700, "Parse error"), status: :bad_request
        end

        private

        def route_mcp_request(req)
            id = req["id"]
            method = req["method"]
            params = req["params"] || {}

            case method
            when "initialize"
                handle_initialize(id, params)
            when "tools/list"
                handle_tools_list(id)
            when "tools/call"
                handle_tools_call(id, params)
            when "resources/list"
                handle_resources_list(id)
            when "resources/read"
                handle_resources_read(id, params)
            else
                error_response(id, -32601, "Method not found: #{method}")
            end
        rescue => e
            error_response(id, -32603, e.message)
        end

        def handle_initialize(id, _params)
            success_response(id, {
                protocolVersion: "2024-11-05",
                capabilities: {
                    tools: { listChanged: false },
                    resources: { subscribe: false, listChanged: false }
                },
                serverInfo: {
                    name: "applied-poetics-api",
                    version: "1.0.0",
                    icon: "https://www.appliedpoetics.org/img/favicon.ico"
                }
            })
        end

        def handle_tools_list(id)
            success_response(id, { tools: McpToolRegistry.tools })
        end

        def handle_tools_call(id, params)
            tool_name = params["name"]
            arguments = params["arguments"] || {}
            result = McpToolRegistry.call(tool_name, arguments)
            success_response(id, {
                content: [ { type: "text", text: result[:result].to_s } ],
                isError: false
            })
        rescue KeyError, ArgumentError => e
            success_response(id, {
                content: [ { type: "text", text: e.message } ],
                isError: true
            })
        end

        def handle_resources_list(id)
            success_response(id, { resources: McpToolRegistry.resources })
        end

        def handle_resources_read(id, params)
            uri = params["uri"]
            content = McpToolRegistry.read_resource(uri)
            if content.nil?
                return error_response(id, -32602, "Resource not found: #{uri}")
            end
            success_response(id, {
                contents: [ {
                    uri: uri,
                    mimeType: "text/plain",
                    text: content
                } ]
            })
        end

        def success_response(id, result)
            { jsonrpc: "2.0", id: id, result: result }
        end

        def error_response(id, code, message)
            { jsonrpc: "2.0", id: id, error: { code: code, message: message } }
        end
    end
end
