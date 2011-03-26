require 'newflow'
class Ivrflow
  include Newflow

  def self.registered_ivr_flows
    @@ivr_flows
  end

  def self.desc d
    @@ivr_flows ||= {}
    puts "Self: #{self}"
    @@ivr_flows[self] = {
      :desc => d
    }
  end
end
