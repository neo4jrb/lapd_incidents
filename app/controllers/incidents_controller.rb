class IncidentsController < ApplicationController
  def index
    render json: Incident.limit(1000)
  end

  def show
    @incident = Incident.find(params[:id])
  end
end
