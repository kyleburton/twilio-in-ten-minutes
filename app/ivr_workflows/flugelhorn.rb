require 'ivrflow'

class Flugelhorn < Ivrflow
  desc "my cool thingamabobber"

  define_workflow do
    state :start, :start => true do
      transitions_to :middle, :if => :just_go?
    end

    state :middle do
      transitions_to :done, :if => :any_input?
    end

    state :done, :stop => true
  end

  def just_go?
    true
  end

  def any_input?
    !sms_body.empty?
  end

  message :start do
    sms "You won't really see this for sms"
  end

  message :middle do
    sms "Tell me all your secret sauces"
  end

  message :done do
    sms "#{sms_body} well I never! I'm alerting the authorities!"
  end
end
