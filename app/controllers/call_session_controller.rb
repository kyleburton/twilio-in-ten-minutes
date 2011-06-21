class CallSessionController < ApplicationController
  layout 'site'
  before_filter :reload_workflows,    :except => [:delete]

  def delete
    Rails.logger.info "delete call: #{params[:id]}"
    CallSession.delete_all(:session_id => params[:id])
    render :content_type => 'text/json', :json => {
      :status => "deleted",
      :session_id => params[:id],
    }
  end

  def show
    @call_session = CallSession.find(params[:id], :order => 'updated_at DESC')
    params[:CallSid] = @call_session.session_id
    find_or_create_session @call_session.workflow_name
    respond_to do |fmt|
      fmt.json { render :json => { :call_session => @call_session, :workflow_history => @workflow.history  } }
      fmt.html
    end
  rescue
    render :show
  end

  def by_sid
    @call_session = CallSession.find_by_session_id(params[:id])
    params[:CallSid] = @call_session.session_id
    find_or_create_session @call_session.workflow_name
    respond_to do |fmt|
      fmt.json { render :json => { :call_session => @call_session, :workflow_history => @workflow.history  } }
      fmt.html { render :template => 'call_session/show' }
    end
  end

  def delete
    @call_session = CallSession.find(params[:id])
    @call_session.destroy if @call_session
    redirect_to console_path
  rescue
    redirect_to '/'
  end
end
