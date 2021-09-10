class ApplicationController < ActionController::Base
  include Pundit
  include Pagy::Backend
end
