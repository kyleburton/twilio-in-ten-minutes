class CallSessionController < ApplicationController
  layout 'site'

  def delete
    Rails.logger.info "delete call: #{params[:id]}"
    CallSession.delete_all(:session_id => params[:id])
    render :content_type => 'text/json', :json => {
      :status => "deleted",
      :session_id => params[:id],
    }
  end

  def show
    @call_session = CallSession.find(params[:id])
    params[:CallSid] = @call_session.session_id
    find_or_create_session @call_session.workflow_name
    respond_to do |fmt|
      fmt.json { render :json => { :call_session => @call_session, :workflow_history => @workflow.history  } }
      fmt.html
    end
  end
end
