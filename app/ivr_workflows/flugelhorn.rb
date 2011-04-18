require 'ivrflow'

class Flugelhorn < Ivrflow

  desc "some awesome new example"

  define_workflow do
    state :start, :start => true do
      transitions_to :second_state, :if => :always_transition?
    end

    state :second_state do
      transitions_to :done, :if => :any_input?
    end

    state :done, :stop => true
  end


  message :start do
    sms "you'll never see this"
  end

  def always_transition?
    true
  end

  message :second_state do
    sms "Go ahead and tell me all your secret sauces hon."
  end

  def any_input?
    !sms_body.empty?
  end

  message :done do
    sms "'#{sms_body}' well I never! I'm alerting the authorities!"
  end

end
