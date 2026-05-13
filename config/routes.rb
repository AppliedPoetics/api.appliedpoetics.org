Rails.application.routes.draw do
    namespace :v1 do
        post "mcp", to: "mcp#create"
        scope "/:cat" do
            scope "/:mtd" do
                post "/", to: "application#create"
            end
        end
    end
end
