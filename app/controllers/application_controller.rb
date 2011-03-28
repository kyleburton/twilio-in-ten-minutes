# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.
require 'twml'

class ApplicationController < ActionController::Base
  helper :all # include all helpers, all the time
  # protect_from_forgery # See ActionController::RequestForgeryProtection for details
  protect_from_forgery :only => [:create, :update, :destroy]

  # Scrub sensitive parameters from your log
  # filter_parameter_logging :password

  protected
  def expire_old_sessions
    @ivr_session_id = call_sid
    CallSession.connection.execute("select id,updated_at at time zone 'gmt' as updated_at,now() at time zone 'gmt' as curr_time from call_sessions").each do |rec|
      t1 = Time.parse(rec["curr_time"])
      t2 = Time.parse(rec["updated_at"])
      age = t1 - t2
      Rails.logger.info "EXPIRE: age:#{age}/#{t2-t1} #{rec.inspect}"
      if age > 120 # seconds
        Rails.logger.info "Expiring session:#{rec["id"]} age=#{age}"
        CallSession.delete(rec["id"])
      end
    end
  end

  def step_workflow
    if !digits.nil? && !digits.empty?
      Rails.logger.info "User input digits: #{digits}"
      before_state = @workflow.current_state
      @workflow.digits = digits
      res = @workflow.transition_once!
      @workflow.set_response
      @workflow.history << { :state => @workflow.current_state, :message => @workflow.message }
      @call_session.state = @workflow.current_state.to_s
      @call_session.workflow_internal_state = @workflow.serialize_workflow
      @call_session.save!
      res
    end
  rescue Exception => e
    Rails.logger.error e
    @error = "Erorr executing workflow: #{e}"
  end

  def find_or_create_session workflow_name
    @call_session = CallSession.find_by_session_id(call_sid)
    if @call_session.nil?
      @workflow     = workflow_name.constantize.new
      @workflow.history << { :state => @workflow.current_state, :message => @workflow.message }
      internal_state = @workflow.serialize_workflow
      Rails.logger.info "workflow state is:'#{internal_state}'"
      @call_session = CallSession.create(
        :session_id     => call_sid,
        :caller_number  => caller_number,
        :workflow_name  => workflow_name,
        :state          => @workflow.workflow_state.to_s,
        :workflow_internal_state => internal_state
      )
    else
      if !caller_number.nil? && !caller_number.empty?
        @call_session.caller_number = caller_number
      end
      @workflow = workflow_name.constantize.new
      @workflow.deserialize_workflow(@call_session.workflow_internal_state)
      @workflow.workflow_state = @call_session.state
    end
    @workflow.set_response
  end

  def digits
    params['Digits'] || ''
  end

  def call_sid
    params['CallSid'] ||= 'Sid-' + Time.now.to_i.to_s + '-' + rand(1_000_000).to_s
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
