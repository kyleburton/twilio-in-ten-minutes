class TWML
  attr_accessor :twml, :body

  # record, sms, dial, number, conference
  # redirect, reject, pause

  def self.response &block
    twml = self.new
    twml.instance_eval &block
    res = twml.twml || twml.body
    raise "Error: no TWML generated!" if res.nil? || res.empty?
    res
  end 

  def self.make_tag_fn name, tag
    define_method(name) do |*args,&block|
      if ended?
        raise "Error: conversation ended with preious tag, subsequent TWML is invalid"
      end
      body = args[0] || ''
      opts = args[1] || {}
      @body += "<#{tag} #{_attrs opts}>"
      @body += body
      instance_eval &block if block_given? || block
      @body += "</#{tag}>"
    end
  end

  def self.make_nested_tag_fn name, tag
    define_method(name) do |*args,&block|
      if ended?
        raise "Error: conversation ended with preious tag, subsequent TWML is invalid"
      end
      opts = args[0] || {}
      @body += "<#{tag} #{_attrs opts}>"
      instance_eval &block if block_given?
      @body += "</#{tag}>"
    end
  end

  def self.make_emtpy_tag_fn name, tag
    define_method(name) do  |*args|
      attrs = _attrs(args[0]||{})
      @body += "<#{tag} #{attrs} />"
    end
  end

  { :say        => "Say",
    :play       => "Play",
    :sms        => "Sms",
    :redirect   => "Redirect",
    :number     => "Number",
    :conference => "Conference",
    :dial       => "Dial"}.each do |name,tag|
    make_tag_fn name, tag
  end

  {:hangup => "Hangup", :reject => "Reject", :pause => "Pause"}.each do |name,tag|
    make_emtpy_tag_fn name, tag
  end

  def initialize &block
    @body = '';
    @ended = false
    return @body if @body.nil? || @body.empty?
    instance_eval &block if block_given?
    @twml = "<Response>\n"
    @twml += @body
    @twml += "</Response>\n"
  end 

  def ended?
    return true if @body.end_with? "<Hangup  />"
    return true if @body.end_with? "<Hangup />"
    return true if @body.end_with? "<Hangup/>"
    return true if @body.end_with? "</Sms>"
    return true if @body.end_with? "</Redirect>"
    return true if @body.end_with? "<Reject  />"
    return true if @body.end_with? "<Reject />"
    return true if @body.end_with? "<Reject/>"
    return false
  end

  def _gather_defaults opts
    { :digits      => '1',
      :timeout     => 5,
      :finishOnKey => '#',
    }.merge opts
  end

  def _attrs opts={}
    attrs = ''
    opts.each do |k,v|
      attrs += "#{k}='#{v}'"
    end
    attrs
  end

  def gather opts={}, &block
    opts = _gather_defaults opts
    @body += "<Gather #{_attrs opts}>\n"
    instance_eval &block if block_given?
    @body += "</Gather>\n"
  end

  def play url, opts={}
    @body += "<Play #{_attrs opts}>#{url}</Play>"
  end

end
