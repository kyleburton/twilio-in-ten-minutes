class QuoteController < ApplicationController

  def initialize
    super
    @quotes = [
      "Does the name Pavlov ring a bell?",
      "Cats, no less liquid than their shadows, offer no angles to the wind.",
      "Cats are smarter than dogs.  You can't make eight cats pull a sled through the snow.",
      "Force has no place where there is need of skill.  By Herodotus",
      "Getting there is only half as far as getting there and back.",
      "Happiness isn't having what you want, it's wanting what you have.",
      "Your happiness is intertwined with your outlook on life.",
      "Your mind understands what you have been taught; your heart, what is true.",
      "Children seldom misquote you.  In fact, they usually repeat word for word what you shouldn't have said.",
      "Cleaning your house while your kids are still growing is like shoveling the walk before it stops snowing.  By Phyllis Diller",
      "The average income of the modern teenager is about 2 a.m."
    ]
  end

  def index
    session[:quote] ||= @quotes[rand @quotes.size]
    app = self
    send_back do
      gather(:action => '/quote/answer', :digits => 1) do
        say "Welcome to the Quote Hotline."
        say "Your Quote is:"
        say app.session[:quote]
        say "Press 1 to hear it again."
        say "Press 2 to disconnect."
      end
    end
  end

  def answer
    app = self
    if digits == "1"
      send_back do
        say "Your Quote is:"
        say app.session[:quote]
        gather(:action => '/quote/answer', :digits => 1) do
          say "Press 1 to hear it again."
          say "Press 2 to disconnect."
        end
      end
    else
      send_back do
        say "Thanks for calling.  Good Bye."
        hangup
      end
    end
  end

end

