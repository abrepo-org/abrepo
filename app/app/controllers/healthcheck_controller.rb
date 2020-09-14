class HealthcheckController < ApplicationController

  def index
    render status: 200, html: "pong"
  end
  
end
