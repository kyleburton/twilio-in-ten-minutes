require 'twml'
require 'newflow'
class Ivrflow
  attr_accessor :digits, :workflow_state, :message, :history
  include Newflow

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
    meth = "#{workflow_state.to_s}_message".to_sym
    if !self.respond_to? meth
      raise "Error: workflow #{self} must implment #{meth} to build the TWML for state #{workflow_state.to_s}"
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
      super(meth, *args, &block)
    end
  end
end
