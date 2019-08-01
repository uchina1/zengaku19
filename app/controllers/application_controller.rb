class ApplicationController < ActionController::Base
	rescue_from ActionController::RoutingError, ActiveRecord::RecordNotFound, with: :render_404
	def render_404
  		redirect_to '/exchanges/index'
	end 
end
