# This class represents an internal DSL for the twilio markup language.
# It uses a technique discussed in:
#   http://www.dcmanges.com/blog/ruby-dsls-instance-eval-with-delegation
# to allow instnce methods to be called on the calling object.
class TWML
  attr_accessor :twml

  def self.response &block
    self.new do
      @outer_self = eval "self", block.binding
      instance_eval &block
    end
  end 

  # see: http://www.dcmanges.com/blog/ruby-dsls-instance-eval-with-delegation
  def method_missing(method, *args, &block)
    @outer_self.send method, *args, &block
  end

  def initialize &block
    # see: http://www.dcmanges.com/blog/ruby-dsls-instance-eval-with-delegation
    @outer_self = eval "self", block.binding
    @twml = "<Response>\n"
    instance_eval &block if block_given?
    @twml += "</Response>\n"
  end 

  def say phrase
    @twml += "#{@indent}<Say>#{phrase}</Say>\n"
  end 

  def gather opts={}, &block
    @twml += "<Gather action=\"#{opts[:action]}\" numDigits=\"#{opts[:digits]||'1'}\" timeout=\"#{opts[:timeout]||5}\" finishOnKey=\"#{opts[:finishOnKey]||'#'}\" method=\"POST\">\n"
    instance_eval &block if block_given?
    @twml += "</Gather>\n"
  end

  def hangup
    @twml += "<Hangup/>\n"
  end

  def play url, opts={}
    @twml += "<Play loop=\"#{opts[:loop]||'1'}\">#{url}</Play>"
  end

end
