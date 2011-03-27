class ConsoleController < ApplicationController
  layout 'site'
  def index
  end

  def active_sessions
    @active_sessions = [
    ]
    @registered_workflows = Ivrflow.registered_ivr_flows
    respond_to do |fmt|
      fmt.json { render :json => @active_sessions }
    end
  end

  def session_info
    @session_info = { :name  => 'active session1', 
                      :state => 'start' }

    respond_to do |fmt|
      fmt.json { render :json => @session_info }
    end
  end
end
