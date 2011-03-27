# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'twml'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details
  protect_from_forgery :only => [:create, :update, :destroy]

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  def digits
    params['Digits'] || ''
  end

  def caller
    params['Caller'] || ''
  end

  def send_back &block
    t = TWML.new do
      instance_eval &block
    end
    render :text => t.twml
  end

end
