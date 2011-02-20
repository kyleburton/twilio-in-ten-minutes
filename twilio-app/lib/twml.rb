class TWML
  attr_accessor :twml

  def self.response &block
    self.new do
      instance_eval &block
    end
  end 

  def initialize &block
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
