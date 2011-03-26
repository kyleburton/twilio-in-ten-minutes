require 'ivrflow'

class CCard < Ivrflow
  attr_accessor :workflow_state

  desc <<-END
This workflow represents a caller registering a Credit Card.
During the registration, after they've entered their credit
card number, we attempt to upsel them on 
  END

  define_workflow do
    state :start, :start => true do
      transitions_to :reask_for_card_number,      :if => :not_card_number_valid?
      transitions_to :ask_for_expensive_services, :if => :card_number_valid?
    end

    state :reask_for_card_number do
      transitions_to :abuse_caller_and_hangup,    :if => :reask_for_card_number_more_than_3_times?
      transitions_to :reask_for_card_number,      :if => :not_card_number_valid?
      transitions_to :ask_for_expensive_services, :if => :card_number_valid?
    end

    state :ask_for_expensive_services do
      transitions_to :weve_got_a_live_one,    :if => :pressed_1?
      transitions_to :scare_user_and_hang_up, :if => :not_pressed_1?
    end

    state :weve_got_a_live_one do
      transitions_to :weve_got_a_live_one,    :if => :pressed_1?
      transitions_to :scare_user_and_hang_up, :if => :not_pressed_1?
    end

    state :scare_user_and_hang_up,  :stop => true
    state :abuse_caller_and_hangup, :stop => true
  end
end
