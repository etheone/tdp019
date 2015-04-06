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
    if @att_skriva_ut.class != String
      puts @att_skriva_ut.eval()
    else
      puts "#{@att_skriva_ut}"
    end
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
    #puts "#{result}"
    return result
  end
end

# Tar hand om evalueringen av jämförelser
class JamfOperator
  attr_accessor :op
  def initialize(op)
    @op = op
  end

  def eval(uttr1,uttr2)
    case @op
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

class LogisktUttryck
  attr_accessor :jamf1, :l_op, :jamf2
  def initialize(j1, op, j2)
    @jamf1 = j1
    @l_op = op
    @jamf2 = j2
  end

  def eval()
    puts "#{@jamf1.eval()} #{@jamf2.eval()} #{@l_op.eval(@jamf1,@jamf2)}"
    return @l_op.eval(@jamf1, @jamf2)
  end
end

class LogiskOperator
  attr_accessor :operator
  def initialize(operator)
    @operator = operator
  end

  def eval(uttr1, uttr2)
    case @operator
    when 'och'
      return (uttr1.eval() and uttr2.eval())
    when 'eller'
      return (uttr1.eval() or uttr2.eval())
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

class Om
  attr_accessor :l_ut, :satser, :annars_satser
  def initialize(l_ut, satser, annars_satser = false)
    @l_ut = l_ut
    @satser = satser
    @annars_satser = annars_satser
  end

  def eval()
    puts "what"
    if @l_ut.eval()
      puts "what2"
      @satser.eval()
    elsif @annars_satser != false
      puts "annars"
      @annars_satser.eval()
    end
  end
end

class Scope
  attr_accessor :variables, :previous_scope
  def initialize(previous)
    @variables = Hash.new
    @previous_scope = previous   
  end

  def add_variable(name, value)
    @variables[name]=value
    puts "\n ¤&¤&¤&¤&¤&&¤&¤&¤& #{@variables[name].eval()} ¤¤¤¤#%#%#¤# \n"
  end
  
  def eval()
  end
end

#class Deklarering
#  @variables = Hash.new
#  def initialize(name, value)
 

