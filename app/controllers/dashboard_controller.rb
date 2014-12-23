class DashboardController < ApplicationController
  def index
    @areas = Area.order(:name)
    @crimes = Crime.order(:description)
  end
end
