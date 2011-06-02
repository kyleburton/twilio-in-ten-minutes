require 'ivrflow'

class Flugelhorn < Ivrflow
  desc "A new awesome SMS based flow"

  define_workflow do
    state :begin, :start => true do
      transitions_to :middle, :if => :any_input?
    end

    state :middle do
      transitions_to :final, :if => :any_input?
    end

    state :final, :stop => true
  end

  def any_input?
    !sms_body.nil?
  end

  message :begin do
    sms "Welome, tell me all your most secret secrets"
  end

  message :middle do
    sms "That's nice dear, what else?"
  end

  message :final do
    sms "#{sms_body}? Well I never!"
  end
end
