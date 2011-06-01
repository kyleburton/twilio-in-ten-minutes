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
    return
    # both sqlite and postgresql support 'select current_timestamp;'
    # SQLITE: select id,current_timestamp - datetime(julianday(updated_at),'unixepoch') from call_sessions;
    # select date('now'),updated_at,julianday(date('now')),julianday(updated_at),julianday(date('now'))-julianday(updated_at) from call_sessions;
    # select date('now'),updated_at,julianday(date('now')),julianday(updated_at),((julianday(date('now'))-julianday(updated_at))*864000) from call_sessions;
    # to detect the adapter, use: CallSession.connection.adapter_name
    @ivr_session_id = twilio_session_id
    CallSession.connection.execute("select id,updated_at at time zone 'gmt' as updated_at,now() at time zone 'gmt' as curr_time from call_sessions").each do |rec|
      t1 = Time.now
      t2 = Time.parse(rec["updated_at"])
      age = t1 - t2
      Rails.logger.info "EXPIRE: age:#{age}/#{t2-t1} vs 120 #{rec.inspect}"
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
      return res
    end

    if !sms_body.nil? && !sms_body.empty?
      {"SmsSid"      => :sms_sid,
       "AccountSid"  => :account_sid,
       "From"        => :sms_from,
       "To"          => :sms_to,
       "Body"        => :sms_body,
       "FromCity"    => :from_city,
       "FromState"   => :from_state,
       "FromZip"     => :from_zip,
       "FromCountry" => :from_country,
       "ToCity"      => :to_city,
       "ToState"     => :to_state,
       "ToZip"       => :to_zip,
       "ToCountry "  => :to_country }.each do |param,method|
        m = "#{method.to_s}=".to_sym
        @workflow.send m, params[param]
      end

      Rails.logger.info "User input SMS: #{@workflow.sms_body}"
      before_state = @workflow.current_state
      res = @workflow.transition_once!
      @workflow.set_response
      @workflow.history << { :state => @workflow.current_state, :message => @workflow.message }
      @call_session.state = @workflow.current_state.to_s
      @call_session.workflow_internal_state = @workflow.serialize_workflow
      @call_session.save!
      return res
    end
  rescue Exception => e
    Rails.logger.error e
    @error = "Erorr executing workflow: #{e}"
  end

  def workflow_stopped?
    @workflow.workflow.states[@workflow.workflow.current_state].stop?
  end

  def find_or_create_session workflow_name
    @call_session = CallSession.find_by_session_id(twilio_session_id)
    if @call_session.nil?
      @workflow     = workflow_name.constantize.new
      @workflow.history << { :state => @workflow.current_state, :message => @workflow.message }
      internal_state = @workflow.serialize_workflow
      if twilio_session_id
        Rails.logger.info "creating new session with sid=#{twilio_session_id}"
        @call_session = CallSession.create(
          :session_id     => twilio_session_id,
          :caller_number  => caller_number,
          :workflow_name  => workflow_name,
          :state          => @workflow.workflow_state.to_s,
          :workflow_internal_state => internal_state
        )
      else
        @call_session = CallSession.new(
          :session_id     => twilio_session_id,
          :caller_number  => caller_number,
          :workflow_name  => workflow_name,
          :state          => @workflow.workflow_state.to_s,
          :workflow_internal_state => internal_state
        )
      end
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

  def sms_body
    params['Body'] || ''
  end

  def sms_from
    params['From'] || ''
  end

  def sms_to
    params['To'] || ''
  end

  def sms_sid
    params['SmsSid'] || ''
  end

  def account_sid
    params['AccountSid'] || ''
  end

  def digits
    params['Digits'] || ''
  end

  def call_sid
    params['CallSid']
  end

  def twilio_session_id
    if params.has_key?('CallSid')
      call_sid
    elsif params.has_key?('SmsSid')
      params['From']
    else
      Rails.logger.warn "Error: invalid request, no CallSid or SmsSid! : #{params.inspect}"
      nil
    end
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

  def reload_workflows
    if RAILS_ENV == 'development'
      Dir.glob("#{RAILS_ROOT}/app/ivr_workflows/*.rb").each do |f|
        Rails.logger.info "reloading: #{f}"
        load f
      end
    end
  end
end
