require 'ivrflow'

class Flugelhorn < Ivrflow
  desc "a new sms based flow"

  define_workflow do
    state :start, :start => true do
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

  message :start do
    say "Welcome, tell me more"
  end

  message :middle do
    say "That's nice dear, what else?"
  end

  message :final do
    say "#{sms_body}? Well I never!"
  end
end
