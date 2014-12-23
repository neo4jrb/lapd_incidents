class IncidentsController < ApplicationController
  def index
    @incidents = Incident.query_as(:incident).limit(200)

    if params[:area_number].present?
      @incidents = @incidents.match("(incident)--(area:Area)").where(area: {number: params[:area_number]})
    end

    if params[:crime_code].present?
      @incidents = @incidents.match("(incident)--(crime:Crime)").where(crime: {code: params[:crime_code]})
    end


    render json: @incidents.pluck(:incident)
  end

  def show
    @incident = Incident.find(params[:id])
  end
end
