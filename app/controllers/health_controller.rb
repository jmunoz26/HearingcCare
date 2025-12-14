class HealthController < ApplicationController
  def index
     render json: { status: "ok", service: "rails-api" }
  end
end
