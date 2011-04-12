require 'ivrflow'

class SMSCard < Ivrflow
  desc <<-END
    Workflow to test out Twilio SMS functionality.
  END

  define_workflow do
    state :start, :start => true do
      transitions_to :say_goodbye, :if => :always_transition
    end

    state :say_goodbye, :stop => true
  end

  def always_transition
    true
  end

  message :start do
    sms "Hi-O!"
  end

  message :say_goodbye do
    sms "Ok Mr '#{sms_body}', it nice talking to ya!"
  end
end
