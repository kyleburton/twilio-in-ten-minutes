require 'ivrflow'

class Flugelhorn < Ivrflow 
  desc "something"
  define_workflow do 
    state :begin, :start => true do
      transitions_to :done, :if => :any_input?
    end

    state :done, :stop => true
  end

  def any_input?
    !sms_body.nil?
  end

  message :begin do
    sms "at start"
  end

  message :done do
    sms "all done"
  end
end
