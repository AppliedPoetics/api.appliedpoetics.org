class ApplicationController < ActionController::API
    def index
        @cat = params[:cat]
        @mtd = params[:mtd]
    end
end
