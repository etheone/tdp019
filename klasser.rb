# -*- coding: utf-8 -*-


class Scope
  attr_accessor :variables, :previous_scope
  def initialize(previous = nil)
    @variables = Hash.new
    @previous_scope = previous   
  end

  def add_variable(name, value)
    @variables[name] = value
    #puts "\n ¤&¤&¤&¤&¤&&¤&¤&¤& #{@variables[name].eval()} ¤¤¤¤#%#%#¤# \n"
  end

  def get_variable(name)
    puts @variables
    puts name
    puts "#{@variables[name]} ''''''''''''''''''''''''"
    if @variables.has_key?(name)
      return @variables[name]
    elsif @previous_scope != nil
      @previous_scope.get_variable(name)
    else
      puts "Something went wrong, variable doesn't exist"
      return nil
    end
  end

  def change_variable(name, value)
    if @variables.has_key?(name)
      @variables[name] = value
    elsif @previous_scope != nil
      @previous_scope.change_variable(name, value)
    else
      puts "Variable not declared"
    end
  end
  
  def eval()
    #Maybe later.
  end
end

# Denna variabel håller en referens till det nuvarande scopet.
# Det sätts till ett nytt scope i klassen Satser
@@nuvarande_scope = nil


## En kommentar om scope:
## I början av eval() sätt scopet om till det nya, det sista som händer i eval()
## är att scopet "hoppar" tillbaka till det föregående.
class Satser
  attr_accessor :satser
  def initialize(satser)
    @satser = satser
  end

  def eval()
    
    @@nuvarande_scope = Scope.new(@@nuvarande_scope)
    
    @satser.each_index do | index |
      puts "Index #{index}: #{@satser[index]}"
    end
    @satser.each do |sats|
      sats.eval()
    end
    
    @@nuvarande_scope = @@nuvarande_scope.previous_scope
  end
end

class SkrivUt
  attr_accessor :att_skriva_ut
  def initialize(att_skriva_ut)
    @att_skriva_ut = att_skriva_ut
  end

  def eval()
    if @att_skriva_ut.class != String
      puts "Inte en String"
      puts @att_skriva_ut.eval()
    else
      puts "#{@@nuvarande_scope.get_variable(@att_skriva_ut).eval()}"
    end
    puts "*********** variabler i  @@nuvarande_scope ****************"
    puts "#{@@nuvarande_scope.variables}"
    if @@nuvarande_scope.previous_scope == nil
      puts "Previous är nil"
    else
      puts "********* variabler i previous_scope *****************"
      puts "#{@@nuvarande_scope.previous_scope.variables}"
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
  def initialize(v, op, h)
    @h_uttryck = h
    @operator = op
    @v_uttryck = v
  end

  def eval()
    temp_h = @h_uttryck
    temp_v = @v_uttryck
    puts "#{temp_v} **************************************************"
    puts "Testning: #{@h_uttryck.class} : #{@v_uttryck.class}"
    if @@nuvarande_scope.variables.has_key?(@v_uttryck)
      temp_v = @@nuvarande_scope.get_variable(@v_uttryck)
    end
    if @@nuvarande_scope.variables.has_key?(@h_uttryck)
      temp_h = @@nuvarande_scope.get_variable(@h_uttryck)
    end
    result = @operator.eval(temp_v, temp_h)
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
      puts "#{uttryck1.class} #{uttryck2.class}"
      #exit()
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
    temp_v = @v_uttryck
    temp_h = @h_uttryck
    if @@nuvarande_scope.variables.has_key?(@v_uttryck)
      temp_v = @@nuvarande_scope.get_variable(@v_uttryck)
    end
    if @@nuvarande_scope.variables.has_key?(@h_uttryck)
      temp_h = @@nuvarande_scope.get_variable(@h_uttryck)
    end
    # Enbart lite tester här just nu
    #puts "Inne i eval() i klassen Jamforelse"
    #puts "Operator-class: #{@op.class}"
    #result = @v_uttryck.eval() > @h_uttryck.eval()
    result = @operator.eval(temp_v, temp_h)
    puts "#{result}"
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
      puts "#{@@nuvarande_scope.variables}"
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

class Deklarering
  attr_accessor :name, :value
  def initialize(name, value = nil)
    @name = name
    @value = value
  end

  def eval()
    #puts "Inne i eval() i Deklarering"
    #puts value.eval()
    @@nuvarande_scope.add_variable(@name, @value)
  end
end


#class Variabel
#  attr_accessor :name
#  def initialize(name)
#    @name = name
#  end

#  def eval()
#    @@nuvarande_scope.get_variable(@name)
# end
#end


class Tilldelning
  attr_accessor :name, :value
  def initialize(name, value)
    @name = name
    @value = value
  end

  def eval()
    # Ingen som helst felkontroll, måste kolla om variabeln är deklarerad
    if @@nuvarande_scope.get_variable(@name) != nil
      temp = Varde.new(@value.eval())
      @@nuvarande_scope.change_variable(@name, temp) 
    end
  end
end

class ForLoop
  attr_accessor :var_namn, :start, :slut, :satser
  def initialize(var_namn,start,slut,satser)
    @var_namn = var_namn
    @start = start.eval()
    @slut = slut.eval()
    @satser = satser
  end

  def eval()
    #puts "Klassen för variabelnamnet: #{@var_namn.class}"
    #puts "Klassen för startvärdet: #{@start.class}"
    #puts "Klassen för slutvärdet: #{@slut.class}"
    #puts "Klassen för satser: #{@satser.class}"

    #@@nuvarande_scope = Scope.new(@@nuvarande_scope)
    
    @start.upto(@slut) do
      @satser.eval()
    end
    #@@nuvarande_scope = @@nuvarande_scope.previous_scope
    
    #for start <= slut
    #  satser.eval()
    #  start += 1
    #end
  end
end


class MedansLoop
  attr_accessor :jamforelse, :satser
  def initialize(jamforelse, satser)
    @jamforelse = jamforelse
    @satser = satser
  end

 
 
 
  def eval()
    while @jamforelse.eval()
      #puts "#{@jamforelse.v_uttryck.eval()} hehehehe #{@jamforelse.v_uttryck}" 
      @satser.eval()
 
    end
  end
end
