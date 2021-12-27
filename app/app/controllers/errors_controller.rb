class ErrorsController < ApplicationController

  def show
    render status_code.to_s, :status => status_code, locals: { code: status_code }
  end

  def maintenance
    # serves maintance.html.erb with no db hit
    render status: 503
  end

  protected

  def status_code
    params[:code]
  end
end
