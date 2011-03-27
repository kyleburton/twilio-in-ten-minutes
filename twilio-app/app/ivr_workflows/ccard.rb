require 'ivrflow'

class CCard < Ivrflow
  attr_accessor :asked_for_card_times

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

  def initialize
    super
    self.asked_for_card_times = 0
  end

  def card_number_valid?
    digits.size == 16
  end

  def start_message
    twml do
      gather(:digits => 16, :timeout => 20) do
        say "Welcome to the La Cosa Nostra credit card activation system."
        say "Please enter your 16 digit card number."
      end
    end
  end

  def reask_for_card_number_message
    twml do
      gather(:digits => 16, :timeout => 20) do
        say "Oh, you're a real smart guy aren't you?"
        say "Enter your 16 digit card number for real this time!"
      end
    end
  end

  def ask_for_expensive_services_message
    twml do
      gather(:digits => 1, :timeout => 20) do
        say "Hey, well done there."
        say "Listen, somebody could totally steal your identity and make charges on your card."
        say "You want we should break their legs if that happens?"
        say "It'll only cost you $99 a month for this protection."
        say "To accept this contract press 1, otherwise press 2."
        say "Don't say we didn't warn you."
      end
    end
  end

  def reask_for_card_number_more_than_3_times?
    @asked_for_card_times > 3
  end

  def weve_got_a_live_one_message
    twml do
      gather(:digits => 1, :timeout => 20) do
        say "It is a reasonable person indeed who values protection."
        say "If you'd like us to find these scumbags and take care of them now, press 1."
        say "Otherwise press 2."
      end
    end
  end
end
