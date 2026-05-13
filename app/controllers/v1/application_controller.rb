module V1
    class ApplicationController < ActionController::API
        # POST v1/:cat/:mtd
        def create
            # Require the presence of :cat and :mtd parameters
            params.expect(:cat, :mtd).present?
            @cat, @mtd = params[:cat], params[:mtd]
            output = Constraint.create(@cat, @mtd, request.POST)
            render json: output, status: :ok
        end

        rescue_from ActionController::ParameterMissing do |exception|
            render json: { error: exception.message }, status: :bad_request
        end

        rescue_from KeyError do |exception|
            render json: { error: exception.message }, status: :bad_request
        end
    end
end
