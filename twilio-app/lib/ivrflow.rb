require 'newflow'
class Ivrflow
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
    puts "Self: #{self}"
    @@ivr_flows[self.to_s] = {
      :desc => d
    }
  end
end
