Rails.application.routes.draw do
    resources "/:cat/:mtd", to: "application#index"
end
