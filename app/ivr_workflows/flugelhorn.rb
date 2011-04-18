
require 'ivrflow'

class Flugelhorn < Ivrflow
  desc <<-END
    Some new flow.
  END

  define_workflow do
    state :start, :start => true do
      transitions_to :done, :if => :a_ok?
    end

    state :done, :stop => true
  end

  def a_ok?
    true
  end

  message :start do
    sms "Hello there, tell me your most secret sauces."
  end

  message :done do
    sms "'#{sms_body}'!  I'm calling the authorities!"
  end


end
