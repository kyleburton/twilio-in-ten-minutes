class WorkflowController < ApplicationController
  layout 'site'

  def show
    name = params[:id]
    @workflow = Ivrflow.new_workflow name
    @graph_png = "/workflows/#{name.downcase}.png"
    if !File.exist?("#{RAILS_ROOT}/public#{@graph_png}")
      flash[:error] = "You need to run 'rake ivr:render_workflows' in your app to generate the workflow graphs."
    end
  end

  def find_or_create_session
    @call_session = CallSession.find_by_session_id(call_sid)
    if @call_session.nil?
      @workflow     = params[:id].constantize.new
      internal_state = @workflow.serialize_workflow
      Rails.logger.info "workflow state is:'#{internal_state}'"
      @call_session = CallSession.create(
        :session_id     => call_sid,
        :caller_number  => caller_number,
        :workflow_name  => params[:id],
        :state          => @workflow.workflow_state.to_s,
        :workflow_internal_state => internal_state
      )
    else
      @workflow = params[:id].constantize.new
      @workflow.deserialize_workflow(@call_session.workflow_internal_state)
      @workflow.workflow_state = @call_session.state
    end
    @workflow.set_response
  end

  def step_workflow
    if !digits.nil? && !digits.empty?
      Rails.logger.info "User input digits: #{digits}"
      before_state = @workflow.current_state
      @workflow.digits = digits
      res = @workflow.transition_once!
      @workflow.set_response
      @call_session.state = @workflow.current_state.to_s
      @call_session.workflow_internal_state = @workflow.serialize_workflow
      @call_session.save!
      res
    end
  rescue Exception => e
    Rails.logger.error e
    @error = "Erorr executing workflow: #{e}"
  end

  def input
    find_or_create_session
    step_workflow
    twml = <<-END
#{@workflow.message}
<!-- Workflow Name:  #{params[:id]} -->
<!-- Workflow State: #{@workflow.current_state} -->
    END
    respond_to do |fmt|
      fmt.json { 
        render :json => {
          :workflow_name  => @call_session.workflow_name,
          :workflow_state => @call_session.state,
          :error          => @error,
          :finished       => @workflow.workflow.states[@workflow.workflow.current_state].stop?,
          :twml           => twml
        }
      }
      fmt.xml { render :content_type => 'text/xml', :text => twml
      }
    end
  end

  private

  def digits
    params['Digits'] || ''
  end

  def call_sid
    params['CallSid'] || ''
  end

  def send_back &block
    t = TWML.new do
      instance_eval &block
    end
    render :text => t.twml
  end

  def caller_number
    params['Caller'] || ''
  end


end
