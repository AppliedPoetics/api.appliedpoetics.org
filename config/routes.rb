Rails.application.routes.draw do
    # Serve Swagger UI at root
    mount Rswag::Ui::Engine => "/"
    # Serve OpenAPI specs
    mount Rswag::Api::Engine => "/api-docs"

    namespace :v1 do
        post "mcp", to: "mcp#create"
        scope "/:cat" do
            scope "/:mtd" do
                post "/", to: "application#create"
            end
        end
    end
end
