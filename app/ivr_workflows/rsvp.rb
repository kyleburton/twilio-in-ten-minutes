require 'ivrflow'

class Rsvp < Ivrflow
  desc <<-END
    RSVP For The Event (yes, the one and only -- my talk ;D
  END

  define_workflow do
    state :start, :start => true do
      transitions_to :start,                     :if => :invalid_rsvp? #:asked_for_help?
      transitions_to :thanks_for_your_rsvp,      :if => :did_rsvp?
      transitions_to :hope_to_see_you_next_time, :if => :negative_rsvp?
    end

    state :thanks_for_your_rsvp do
      transitions_to :all_done,      :if => :any_input?
    end

    state :hope_to_see_you_next_time do
      transitions_to :all_done,      :if => :any_input?
    end

    state :all_done, :stop => true
  end

  def negative_rsvp?
    sms_body =~ /(?i:no|negative|saxaphone)/
  end

  def asked_for_help?
    sms_body =~ /(?i:help|rsvp|philly\s+lambda)/
  end

  def invalid_rsvp?
    !negative_rsvp? && !did_rsvp?
  end

  def did_rsvp?
    sms_body =~ /(?i:yes|ok|go|flugelhorn)/
  end

  message :start do
    sms "To RSVP, reply with {yes, ok, go, flugelhorn}, to Bug out, {no, negative, saxaphone}"
  end

  message :thanks_for_your_rsvp do
    sms "Great, see you there! (winners really do RSVP)"
  end

  message :hope_to_see_you_next_time do
    sms "Sorry to hear that, you'll be missing a _great_ talk.  Enjoy your evening alone in /r/transformers."
  end

  def any_input?
    sms_body.size > 0
  end


  message :all_done do
    sms "Uh, still hanging around eh? (Since you couldn't tell, we're through here, go find something better to do)."
  end
end
