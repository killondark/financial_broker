class ApplicationController < ActionController::Base
  rescue_from ActiveRecord::RecordNotFound do |e|
    render json: { errors: "#{e.model.underscore.humanize} not found" }, status: :not_found
  end

  def render_interactor_result(interactor, attrs = {})
    if interactor.success?
      render json: interactor.value!, **attrs
    else
      render_failure_interactor_result(interactor)
    end
  end

  def render_failure_interactor_result(interactor)
    render json: { errors: interactor.failure }, status: :unprocessable_entity
  end
end
