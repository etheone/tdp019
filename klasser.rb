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
    puts @att_skriva_ut.eval()
  end
end

class Varde
  attr_accessor :varde
  def initialize(varde)
    @varde = varde
  end

  def eval()
    #puts "Värdet på Varde: #{@varde}"
    return @varde
  end
end

class AritmUttryck
  attr_accessor :h_uttryck, :operator, :v_uttryck
  def initialize(h, op, v)
    @h_uttryck = h
    @operator = op
    @v_uttryck = v
  end

  def eval()
    #puts "Testning: #{@h_uttryck.class} : #{@v_uttryck.class}"
    result = @operator.eval(@h_uttryck, @v_uttryck)
    puts result # Skriver ut värdet för testning, ska tas bort
    result
  end
end

# Tar hand funktionaliteten addition, subtraktion,
# multiplikation och division
class AritmOperator
  attr_accessor :operator
  def initialize(operator)
    @operator = operator
  end

  def eval(uttryck1, uttryck2)
    case @operator
    when '+'
      return uttryck1.eval() + uttryck2.eval()
    when '-'
      return uttryck1.eval() - uttryck2.eval()
    when '*'
      return uttryck1.eval() * uttryck2.eval()
    when '/'
      return uttryck1.eval() / uttryck2.eval()
    end
  end
end

class Jamforelse
  attr_accessor :v_uttryck, :operator, :h_uttryck
  def initialize(v_uttr, op, h_uttr)
    @v_uttryck = v_uttr
    @operator = op
    @h_uttryck = h_uttr
  end

  def eval()
    # Enbart lite tester här just nu
    #puts "Inne i eval() i klassen Jamforelse"
    #puts "Operator-class: #{@op.class}"
    #result = @v_uttryck.eval() > @h_uttryck.eval()
    result = @operator.eval(@v_uttryck, @h_uttryck)
    puts "#{result}"
  end
end

# Tar hand om evalueringen av jämförelser
class JamfOperator
  attr_accessor :op
  def initialize(op)
    @op = op
  end

  def eval(uttr1,uttr2)
    case op
    when '>'
      return uttr1.eval() > uttr2.eval()
    when '>='
      return uttr1.eval() >= uttr2.eval()
    when '<'
      return uttr1.eval() < uttr2.eval()
    when '<='
      return uttr1.eval() <= uttr2.eval()
    when '=='
      return uttr1.eval() == uttr2.eval()
    when '!='
      return uttr1.eval() != uttr2.eval()
    end
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
    #puts "#{@temp}"
  end
end

