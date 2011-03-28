require 'twml'
require 'newflow'
class Ivrflow
  attr_accessor :digits, :workflow_state, :message, :history
  include Newflow
  @@message_procs = {}

  def self.registered_ivr_flows
    @@ivr_flows
  end

  def self.new_workflow name
    if @@ivr_flows[name]
      name.constantize.new
    else
      nil
    end
  end

  def self.desc d
    @@ivr_flows ||= {}
    #puts "Self: #{self}"
    @@ivr_flows[self.to_s] = {
      :desc => d
    }
  end

  def initialize
    super
    @history = []
    set_response
  end

  def serialize_workflow
    ignore = { 
      "@workflow"         => true,
      "@message"          => true,
      "@digits"           => true,
      "@workflow_state"   => true,
    }
    m = {}
    self.instance_variables.each do |v|
      next if ignore[v]
      m[v] = self.instance_variable_get v
    end
    m.to_yaml
  end

  def deserialize_workflow data
    m = YAML.load(data)
    m.each do |k,v|
      self.instance_variable_set k, v
    end
  end

  def set_response
    state = workflow_state.to_s
    meth = "#{state}_message".to_sym
    if !self.respond_to? meth
      #require 'ruby-debug'; debugger
      if @@message_procs[self.class] && @@message_procs[self.class][state.to_sym]
        p = @@message_procs[self.class][state.to_sym]
        t = TWML.new self, &p
        return @message = t.twml
      else
        raise "Error: workflow #{self} must implment #{meth} to build the TWML for state #{state}"
      end
    end
    @message = self.send meth
  end

  def twml &block
    t = TWML.new do
      instance_eval &block
    end
    t.twml
  end

  def method_missing(meth, *args, &block)
    # pressed a specific number sequence
    if meth.to_s =~ /^pressed_(\d+)\?$/
      return !digits.nil? && !digits.empty? && digits == $1
    elsif meth.to_s =~ /^not_pressed_(\d+)\?$/
      return !digits.nil? && !digits.empty? && digits != $1
    # entered a specific count of digits
    elsif meth.to_s =~ /^entered_(\d+)_digits\?$/
      num_digits = $1.to_i
      return !digits.nil? && !digits.empty? && digits.size == num_digits
    elsif meth.to_s =~ /^not_entered_(\d+)_digits\?$/
      num_digits = $1.to_i
      return !digits.nil? && !digits.empty? && digits.size != num_digits
    elsif meth.to_s =~ /^not_(.+)$/
      method = $1.to_sym
      if self.respond_to? method
        !self.send method
      else
        super
      end 
    else
      puts "DEFERRING TO SUPER: #{meth}"
      super(meth, *args, &block)
    end
  end

  def self.message(state,&block)
    puts "[#{self}] message for #{state.inspect} via block:#{block}"
    @@message_procs       ||= {}
    @@message_procs[self] ||= {}
    @@message_procs[self][state] = block
  end
end
