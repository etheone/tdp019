# -*- coding: utf-8 -*-
@@debug = false

class Scope
  attr_accessor :variables, :previous_scope
  def initialize(previous = nil)
    @variables = Hash.new
    @previous_scope = previous   
  end

  def add_variable(name, value)
    @variables[name] = value
   
  end

  def get_variable(name)
    #puts @variables
    puts "DEBUG: GETTING VARIABLE" if @@debug
   # puts "#{@variables[name]} ''''''''''''''''''''''''"
    if @variables.has_key?(name)
      return @variables[name]
    elsif @previous_scope != nil
      @previous_scope.get_variable(name)
    else
      puts "Something went wrong, variable doesn't exist"
      return "No variable"
    end
  end

  def change_variable(name, value)
    puts "DEBUG: CHANGING VARIABLE" if @@debug
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

  def eval(lokala_variabler = nil)
    puts "DEBUG: EVALUERAR SATSER" if @@debug
    @@nuvarande_scope = Scope.new(@@nuvarande_scope)

    # Här kollar vi om det ska läggas till några lokala variabler till
    # nuvarande scope
    if lokala_variabler == nil
      puts "DEBUG: inga lokalavariabler att addera till scopet" if @@debug
    else
      puts "DEBUG: Ska addera något till scopet!" if @@debug
      lokala_variabler.each do |k, v|
        #puts "#{k} : #{v}"
        @@nuvarande_scope.add_variable(k, Varde.new(v))
      end
    end
    
    #@satser.each_index do | index |
    #  puts "Index #{index}: #{@satser[index]}"
    #end
    
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
      puts "DEBUG: Inte en String" if @@debug
      puts "DEBUG: #{@att_skriva_ut.class}" if @@debug
      puts "#{@att_skriva_ut.eval()}"
      puts "DEBUG ********************" if @@debug
    else
      puts "DEBUG: #{@@nuvarande_scope.get_variable(@att_skriva_ut).eval()}" if @@debug
    end
    puts "DEBUG variabler i  @@nuvarande_scope DEBUG" if @@debug
    puts "#{@@nuvarande_scope.variables}" if @@debug
    puts "DEBUG: #{@@nuvarande_scope.variables}" if @@debug

    if @@nuvarande_scope.previous_scope == nil
      puts "DEBUG: Previous är nil" if @@debug
    else
      puts "DEBUG variabler i previous_scope DEBUG" if @@debug
      puts "#{@@nuvarande_scope.previous_scope.variables}" if @@debug
      # puts "#{@@nuvarande_scope.previous_scope.variables}"
    end
  end
end

class Varde
  attr_accessor :varde
  def initialize(varde)
    @varde = varde
  end

  def eval()
    puts "DEBUG: EVALUERAR VÄRDE" if @@debug
    return @varde
  end
end

#class StringUttryck
#  attr_accessor :v_string, :operator, :h_string
#  def initialize(v, op, h)
#    @v_string = v
#    @operator = op
#    @h_string = h
#  end

#  def eval()
#    puts "DEBUG: EVALUERAR BERÄKNING PÅ STRÄNG!" if @@debug
#    puts "VSTRING: #{@v_string.class}     OPERATOR: #{@operator.class}       HSTRING: #{@h_string.class}"
    
#  end
#end

class AritmUttryck
  attr_accessor :h_uttryck, :operator, :v_uttryck
  def initialize(v, op, h)
    @h_uttryck = h
    @operator = op
    @v_uttryck = v
  end

  def eval()
    puts "DEBUG: EVALUERAR ARITM UTTRYCK" if @@debug
    temp_h = @h_uttryck
    temp_v = @v_uttryck
    puts "DEBUG #{temp_v} ************************************************** #{temp_h}" if @@debug
    puts " DEBUG: Testning: #{@h_uttryck} : #{@v_uttryck}" if @@debug
    if @@nuvarande_scope.variables.has_key?(@v_uttryck)
      temp_v = @@nuvarande_scope.get_variable(@v_uttryck)
    end
    if @@nuvarande_scope.variables.has_key?(@h_uttryck)
      temp_h = @@nuvarande_scope.get_variable(@h_uttryck)
    end
    puts "#{temp_v.eval()} and #{temp_h.eval()} <---------" if @@debug
    result = @operator.eval(temp_v, temp_h)
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
    puts "DEBUG: UTFÖR ARITM BERÄKNING VARIABLE" if @@debug

    case @operator
    when '+'
      return uttryck1.eval() + uttryck2.eval()
    when '-'
      return uttryck1.eval() - uttryck2.eval()
    when '*'
      return uttryck1.eval() * uttryck2.eval()
    when '/'
      return uttryck1.eval() / uttryck2.eval()
    when '^'
      return uttryck1.eval() ** uttryck2.eval()
    when '%'
      return uttryck1.eval() % uttryck2.eval()
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
    puts "DEBUG: #{result}" if @@debug
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
      puts "#{@@nuvarande_scope.variables}" if @@debug
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
    puts "#{@jamf1.eval()} #{@jamf2.eval()} #{@l_op.eval(@jamf1,@jamf2)}" if @@debug
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
    if @l_ut.eval()
      @satser.eval()
    elsif @annars_satser != false
      @annars_satser.eval()
    end
  end
end

class Deklarering
  attr_accessor :name, :value
  def initialize(name, value = nil)
    @name = name.name
    @value = value
  end

  def eval()
    #puts "Inne i eval() i Deklarering"
    #puts value.eval()
    @@nuvarande_scope.add_variable(@name, @value)
  end
end


class Variabel
  attr_accessor :name
  def initialize(name)
    @name = name
  end

  def eval()
    puts "DEBUG (LINE 336 klasser.rb): VARIABLE IS: #{@name}" if @@debug
    @@nuvarande_scope.get_variable(@name).eval()
 end
end


class Tilldelning
  attr_accessor :name, :value, :operator
  def initialize(name, value = nil, op = nil)
    @name = name.name
    @value = value
    @operator = op
  end

  def eval()
    # Ingen som helst felkontroll, måste kolla om variabeln är deklarerad
    if @operator == nil
      if @@nuvarande_scope.get_variable(@name) != "No variable"
        puts "#{@@nuvarande_scope.get_variable(@name).eval()} ***********************************" if @@debug
        temp = Varde.new(@value.eval())
        @@nuvarande_scope.change_variable(@name, temp)
      end
    else
      if @@nuvarande_scope.get_variable(@name) != "No variable"
        case @operator
        when '+='
          temp = Varde.new(@@nuvarande_scope.get_variable(@name).eval() + @value.eval())
          puts temp if @@debug
        when '-='
          temp = Varde.new(@@nuvarande_scope.get_variable(@name).eval() - @value.eval())
          puts temp if @@debug
        when '*='
          temp = Varde.new(@@nuvarande_scope.get_variable(@name).eval() * @value.eval())
          puts temp if @@debug
        when '/='
          temp = Varde.new(@@nuvarande_scope.get_variable(@name).eval() / @value.eval())
          puts temp if @@debug
        end
        puts "KOM HITEN DÅ" if @@debug
        @@nuvarande_scope.change_variable(@name, temp)
      end
    end
  end
end

class ForLoop
  attr_accessor :var_namn, :start, :slut, :satser
  def initialize(var_namn = nil,start,slut,satser)
    @var_namn = var_namn.name
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
    
    @start.upto(@slut) do |i|
      @satser.eval({@var_namn=>i})
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

################ LISTOR #####################
class Lista
  attr_accessor :array
  def initialize(value = [])
    @array = []
    #puts "XXXXXXXXXXXXXXXXXXXXXXXXXXXXX DEBUG: INITIERAR LISTA #{value.eval()}"
    if value != []
      1.upto(value.length) { |i|
        if value[i-1].class == Varde
          @array << value[i-1].eval()
        else
          @array << value[i-1]
        end
      }          
    else
      @array
    end
  end

  def eval()
    @array
  end
end

class ParLista
  attr_accessor :hash
  def initialize(hash=Hash.new)
    @hash = Hash.new
    puts "DEBUG: TRYING TO INITIATE PARLIST" if @@debug
    hash.each do |k,v|
      if k.class == Varde
        @hash[k.eval()] = v.eval()
      else
        @hash[k] = v
      end
    end
  end

  def eval()
    temp = Hash.new
    @hash.each do |k,v|
      if k.class == Varde
        temp[k.eval()] = v.eval()
      else
        temp[k] = v
      end
    end
    temp
  end
end

class LaggTillILista
  attr_accessor 
  def initialize(name, value, key=nil, more_to_add=nil)
    @list_name = name
    @key = key
    @value = value
    @more_to_add = more_to_add
  end

  def eval()
    listan = @@nuvarande_scope.get_variable(@list_name.name).eval()
    if @key == nil
      listan << @value.eval()
      if @more_to_add != nil
        @more_to_add.each do |item|
          puts "DEBUG: #{item.eval()}" if @@debug
          listan << item.eval()
        end
      end
      @@nuvarande_scope.change_variable(@list_name.name, Lista.new(listan))
    elsif @key != nil
      puts "DEBUG: TRYING TO ADD SOMETHING TO PARLIST" if @@debug
      listan[@key.eval()] = @value.eval()
      puts "DEBUG: #{@key.eval()} for key and #{@value.eval()} for value" if @@debug
      if @more_to_add != nil
        @more_to_add.each do |k,v|
          puts "DEBUG: Key: #{k.eval()} and Value: #{v.eval()}" if @@debug
          listan[k.eval()] = v.eval()
        end
      end
      @@nuvarande_scope.change_variable(@list_name.name, ParLista.new(listan))
    else
      return "ERROR: LISTERROR"
    end
  end
end

class TaBortVardeILista
  attr_accessor :list_name, :value
  def initialize(list_name, value, parlist = false)
    @list_name = list_name
    @value = value
  end

  def eval()
    array = @@nuvarande_scope.get_variable(@list_name.name).eval()
    if array.class != Array
      puts @value.eval() if @@debug
      array.delete(@value.eval())
    else
      array = array - [value.eval()]
    end
    print "DEBUG: #{array}" if @@debug
    if array.class != Array
      @@nuvarande_scope.change_variable(@list_name.name, ParLista.new(array))
    else
      @@nuvarande_scope.change_variable(@list_name.name, Lista.new(array))
    end
  end
end

class AndraVardeILista
  attr_accessor :list_name, :parlist, :value, :new_value
  def initialize(name, value, new_value, parlist = false)
    @list_name = name
    @parlist = parlist
    @value = value
    @new_value = new_value
  end

  def eval()
    listan = @@nuvarande_scope.get_variable(@list_name.name).eval()
   
    if listan.class == Array
      puts "DEBUG: KOM HIIIIIIT NR 2" if @@debug
      listan[@value.eval()] = @new_value[0].eval()
      puts "DEBUG: KOM HIIIIIIT NR 3" if @@debug
      @@nuvarande_scope.change_variable(@list_name.name, Lista.new(listan))
    elsif listan.class == Hash
      listan[@value.eval()] = @new_value[0].eval()
      @@nuvarande_scope.change_variable(@list_name.name, ParLista.new(listan))
    else
      puts "AN ERROR SO MASSIVE THAT IT SHOULD NEVER HAPPEN"
    end
      
  end
end

class ListLoop
  attr_accessor :list, :satser, :iterator1, :iterator2
  def initialize(list_name, satser, iterator1, iterator2=nil)
    @list = list_name.name
    @satser = satser
    @iterator1 = iterator1.name
    @iterator2 = iterator2.name if iterator2 != nil
  end

  def eval()
    puts "DEBUG: list: #{@list}"
    puts "DEBUG: satser: #{@satser.class}"
    puts "DEBUG: iterator1: #{@iterator1}"
    puts "DEBUG: iterator2: #{@iteratir2}"

    # Hämta hem listan som vi ska iterera över
    actual_list = @@nuvarande_scope.get_variable(list).eval()
    puts "DEBUG: actual_list: #{actual_list}" if @@debug

    # Kolla om det är en Array eller en Hash som ska itereras över
    if actual_list.class == Array 
      actual_list.each do | value |
        satser.eval({@iterator1 => value})
      end
    else
      puts "#{actual_list.class}" if @@debug
      actual_list.each do | key, value |
        satser.eval({@iterator1 => key, @iterator2 => value})
      end
    end 
  end
end

############# SLUT PÅ LISTOR #####################3

############# FUNKTIONER #########################

class FunktionsDeklarering
  attr_accessor :name, :satser, :params
  def initialize(name, satser, params = nil)
    @name = name
    @satser = satser
    @params = params
  end

  def eval()
    # TODO - Ska endast kunna lägga till i global scope

    @@nuvarande_scope.add_variable(@name.name, [@params,@satser])
  end

end

class ParameterLista
  attr_accessor :params
  def initialize(params)
    @params = params
  end

  def eval()
    puts "Inne i eval i parameterlista"
  end
end

class FunktionsAnrop
  attr_accessor :name, :args
  def initialize(name, args = nil)
    @name = name
    @args = args
  end

  def eval()
    args_hash = Hash.new
    
    # Hämtar hem parametrarna till funktionen
    funk_params = @@nuvarande_scope.get_variable(@name.name)[0]
    # Kolla så att längderna på parametrar och argument stämmer
    if funk_params.params.length != @args.params.length
      puts "MAJOR ERROR!!! Mismatch args and params when calling funktion: #{@name.name}"
    else
      0.upto(@args.params.length - 1) do |i|
        args_hash[funk_params.params[i].name] = @args.params[i].eval()
        #puts "Funk: #{funk_params.params[i].name}"
        #puts "Arg: #{@args.params[i].eval()}"
      end
    end
    @@nuvarande_scope.get_variable(@name.name)[1].eval(args_hash)
  end
end



############# SLUT PÅ FUNKTIONER #################
