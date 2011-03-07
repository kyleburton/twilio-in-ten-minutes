require 'rubygems'
require 'hpricot'
require File.join(File.dirname(__FILE__),'..','lib','twml')
require 'ruby-debug'

module SpecHelper 
  def xml d
    Hpricot(d)
  end

  def twmlx &block
    res = TWML.response do
      instance_eval &block
    end
    xml(res)
  end
end
