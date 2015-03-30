# -*- coding: utf-8 -*-

class Satser
  attr_accessor :satser
  def initialize(satser)
    @satser = satser
  end

  def eval()
    @satser.each_index do | index |
      puts "Index #{index}: #{@satser[index]}"
    end
    @satser.each do |sats|
      sats.eval()
    end
  end
end

class SkrivUt
  attr_accessor :att_skriva_ut
  def initialize(att_skriva_ut)
    @att_skriva_ut = att_skriva_ut
  end

  def eval()
    puts "#{@att_skriva_ut}"
  end
end

###################################
# En ganska onödig klass som man  #
# antagligen kommer kunna ta bort #
###################################
class NyRad
  attr_accessor :temp
  def initialize()
    @temp = "ny_rad"
  end

  def eval()
    puts "#{@temp}"
  end
end

