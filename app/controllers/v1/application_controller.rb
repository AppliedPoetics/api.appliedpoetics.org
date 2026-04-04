module V1
    class ApplicationController < ActionController::API
        # POST v1/:cat/:mtd
        def create
            @cat, @mtd = params[:cat], params[:mtd]
            output = Constraint.create(@cat, @mtd)
            render json: output, status: :ok
        end
    end
end