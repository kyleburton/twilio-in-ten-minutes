class ConsoleController < ApplicationController
  layout 'site'
  def index
  end

  def active_sessions
    @active_sessions = [
      { :id => 1, :name => 'active session1' },
      { :id => 2, :name => 'active session2' },
      { :id => 3, :name => 'active session3' },
      { :id => 4, :name => 'active session4' },
    ]
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
