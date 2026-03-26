class ApplicationController < ActionController::API
    def create
        @cat, @mtd = params[:cat], params[:mtd]
        task = Constraint.create(@cat, @mtd)
        render json: task, status: :ok
    end
end
