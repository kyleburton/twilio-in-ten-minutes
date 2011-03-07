require File.join(File.dirname(__FILE__),'spec_helper')

describe TWML do 
  include SpecHelper

  it "errors if empty" do
    lambda {
      twmlx do
        # do nothing
      end
    }.should raise_error
  end

  it "Speaks text" do
    (twmlx { say "Hello" }/"say").inner_html.should == "Hello"
  end

  it "Speaks text (constructor)" do
    twml = TWML.new do 
      say "Hello"
    end
    (xml(twml.body)/"say").inner_html.should == "Hello"
  end

  it "Speaks text (woman, fr)" do
    res = twmlx {
      say "Bonjour", :voice => "woman", :language => "fr", :loop => "3"
    }
    
    (res/"say").inner_html.should                   == "Bonjour"
    (res/"say").first.attributes['voice'].should    == "woman"
    (res/"say").first.attributes['language'].should == "fr"
    (res/"say").first.attributes['loop'].should     == "3"
  end

  it "gathers digits" do
    res = twmlx do
      gather(:action => '/foo') do
        say "Press 1 or 2" 
      end
    end
    
    (res/"gather").first.attributes['action'].should == "/foo"
    (res/"say").inner_html.should == "Press 1 or 2"
  end

  it "should hangup" do
    res = twmlx do
      say "Goodbye" 
      hangup
    end
    
    (res/"hangup").first.should_not be_nil
    (res/"say").inner_html.should == "Goodbye"
  end

  it "should play" do
    res = twmlx do
      play "http://foo.com/cowbell.mp3", :loop => 3
    end
    
    (res/"play").first.attributes['loop'].should == "3"
    (res/"play").inner_html.should == "http://foo.com/cowbell.mp3"
  end

  it "should text you cowboy" do
    res = twmlx do
      sms "Message and Data Rates may apply."
    end
    
    (res/"sms").inner_html.should == "Message and Data Rates may apply."
  end

  it "errors if you put anything after hangup (tsk tsk)" do
    lambda {
      twmlx do
        hangup
        say "But you wouldn't hear this!"
      end
    }.should raise_error
  end

  it "errors if you put anything after sms (docs say this is invalid)" do
    lambda {
      twmlx do
        sms "This ends the call"
        say "But you wouldn't hear this!"
      end
    }.should raise_error
  end

  it "dials another number" do
    res = twmlx do
      dial "867-5309"
    end
    
    (res/"dial").inner_html.should == "867-5309"
  end

  it "tries to dial multiple numbers" do
    res = twmlx do
      dial do
        number "867-5308"
        number "867-5309"
        number "867-5310"
      end
    end
    
    (res/"dial"/"number").size.should  == 3
    (res/"dial"/"number").first.inner_html.should == "867-5308"
    (res/"dial"/"number").last.inner_html.should  == "867-5310"
  end
end
