# -*- coding: utf-8 -*-

# Använda för att sätta på/av debug-utskrifter
@@debug = false

# Denna variabel håller en referens till det nuvarande scopet.
# Det sätts till ett nytt scope i klasserna Satser och FSatser
@@nuvarande_scope = nil


################################################
# Klass som tillhandahåller funktionalitet för #
# att hantera scope                            #
################################################
class Scope
  attr_accessor :variables, :previous_scope
  def initialize(previous = nil)
    @variables = Hash.new
    @previous_scope = previous   
  end

  # Lägg till en variabel i scopet
  def add_variable(name, value)
    @variables[name] = value
  end

  # Rekursiv funktion som returnerar värdet på en variabel
  def get_variable(name)
    puts "DEBUG: GETTING VARIABLE" if @@debug
    if @variables.has_key?(name)
      return @variables[name]
    elsif @previous_scope != nil
      @previous_scope.get_variable(name)
    else
      puts "Something went wrong, variable #{name} doesn't exist"
      puts "Current scope: #{@variables}"
      return "No variable"
    end
  end

  # Rekursiv funktion som ändrar värdet på en variabel
  def change_variable(name, value)
    puts "DEBUG: CHANGING VARIABLE" if @@debug
    if @variables.has_key?(name)
      @variables[name] = value
    elsif @previous_scope != nil
      @previous_scope.change_variable(name, value)
    else
      puts "Variable not declared"
    end
    :ok
  end
end

###################################################################
# Klassen Satser håller en lista med alla satser som ett program, #
# loop, funktion eller om-sats innehåller.                        #
# Det är i början av dess eval-funktion som ett nytt scope sätts  #
# för dessa satser som ska evalueras och sedan återgår man till   #
# gamla scopet då alla satser har evaluerats.                     #
###################################################################
class Satser
  attr_accessor :satser
  def initialize(satser)
    @satser = satser
  end

  def eval(lokala_variabler = nil)
    puts "DEBUG: EVALUERAR SATSER" if @@debug

    # Skapar ett nytt scope
    @@nuvarande_scope = Scope.new(@@nuvarande_scope)

    # Här kollar vi om det ska läggas till några lokala variabler till
    # nuvarande scope
    if lokala_variabler == nil
      puts "DEBUG: inga lokalavariabler att addera till scopet" if @@debug
    else
      puts "DEBUG: Ska addera något till scopet!" if @@debug
      lokala_variabler.each do |k, v|
        @@nuvarande_scope.add_variable(k, Varde.new(v))
      end
    end
    #@satser.each_index do | index |
     # puts "Index #{index}: #{@satser[index]}"
     # @satser.each do |sats|
      #  puts "Under index: #{sats}"
      #end
    #end
    # Itererar och evaluerar alla satser
    @satser.each do |sats|
      
      # Kolla om satsen är av typen AvbrytLoop
      if sats.class == AvbrytLoop
        @@nuvarande_scope = @@nuvarande_scope.previous_scope
        return "avbryt"
      end
      
      # Kolla om satsen som ska evalueras är av typen Returnera,
      # i så falls returneras evalueringen av satsen
      if sats.class == Returnera
        result = Varde.new(sats.eval())
        @@nuvarande_scope = @@nuvarande_scope.previous_scope
        return result
      end

      eval_result = sats.eval()

      # Kolla om sats.eval() returnerar "avbryt", i så fall returnera "avbryt"
      if eval_result == "avbryt"
        @@nuvarande_scope = @@nuvarande_scope.previous_scope
        return "avbryt"
      end

      # Kolla om sats.eval() returnerar ett Värde-objekt, i så fall returneras detta
      if eval_result.class == Varde
        @@nuvarande_scope = @@nuvarande_scope.previous_scope
        #result = eval_result.eval()
        #break
        return eval_result
      end
      
    end
    # Efter att satserna evaluerats, sätt scopet tillbaka till
    # det föregående
    @@nuvarande_scope = @@nuvarande_scope.previous_scope
    :ok
  end
end

#################################################
# Klass för att utskrifter till standard output #
#################################################
class SkrivUt
  attr_accessor :att_skriva_ut
  def initialize(att_skriva_ut)
    @att_skriva_ut = att_skriva_ut
  end

  def eval()
    if @att_skriva_ut.eval() == true
      puts "sant"
    elsif @att_skriva_ut.eval() == false
      puts "falskt"
    else
      puts "#{@att_skriva_ut.eval()}"
    end
  end
end

##############################
# Container-klass för värden #
##############################
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

#################################
# Klass för aritmetiska uttryck #
#################################
class AritmUttryck
  attr_accessor :v_uttryck, :operator, :h_uttryck
  def initialize(v, op, h)
    @v_uttryck = v
    @operator = op
    @h_uttryck = h
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

####################################################
# Tar hand funktionaliteten addition, subtraktion, #
# multiplikation, division, upphöjt och modulo     #
####################################################
class AritmOperator
  attr_accessor :operator
  def initialize(operator)
    @operator = operator
  end

  def eval(uttryck1, uttryck2)
    puts "DEBUG: UTFÖR ARITM BERÄKNING VARIABLE" if @@debug

    if uttryck1.eval().class == String || uttryck2.eval().class == String
      uttryck1 = Varde.new(uttryck1.eval().to_s) if uttryck2.eval().class == String
      uttryck2 = Varde.new(uttryck2.eval().to_s) if uttryck1.eval().class == String
    end

    if uttryck1.eval() == "true" || uttryck2.eval() == "false"
      uttryck1 = Varde.new("sant") if uttryck1.eval() == "true"
      uttryck2 = Varde.new("falskt") if uttryck2.eval() == "false"
    end
      
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

#########################
# Klass för jämförelser #
#########################
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
    result = @operator.eval(temp_v, temp_h)
    puts "DEBUG: #{result}" if @@debug
    return result
  end
end

###########################################
# Tar hand om evalueringen av jämförelser #
###########################################
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

#############################
# Klass för logiska uttryck #
#############################
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

###############################################
# Tar hand om evalueringen av logiska uttryck #
###############################################
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


####################################################
# En ganska onödig klass men som ändå måste finnas #
# då det i språket finns en del krav på nyrader.   #
####################################################
class NyRad
  attr_accessor :temp
  def initialize()
    @temp = "ny_rad"
  end

  def eval()
  end
end

###################################
# Klass som tar hand om Om-satser #
###################################
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

###################################
# Klass för variabeldeklareringar #
###################################
class Deklarering
  attr_accessor :name, :value
  def initialize(name, value = nil)
    @name = name.name
    @value = value
  end

  def eval()
    # Hantering av funktionsanrop
    if @value == nil
      @@nuvarande_scope.add_variable(@name, @value)
    else
      @@nuvarande_scope.add_variable(@name, Varde.new(@value.eval()))
    end

=begin    if value.class == FunktionsAnrop
      value_temp = Varde.new(value.eval())
      if value_temp == nil
        @@nuvarande_scope.add_variable(@name, value_temp)
      else
        @@nuvarande_scope.add_variable(@name, Varde.new(value_temp.eval()))
      end
    else
      if @value == nil
        @@nuvarande_scope.add_variable(@name, @value)
      else
        @@nuvarande_scope.add_variable(@name, Varde.new(@value.eval()))
      end
    end
=end    
    :ok
  end
end

#######################################
# En klass för hantering av variabler #
#######################################
class Variabel
  attr_accessor :name
  def initialize(name)
    @name = name
  end

  def eval()
    puts "DEBUG (LINE 385 klasser.rb): VARIABLE IS: #{@name}" if @@debug
    @@nuvarande_scope.get_variable(@name).eval()
 end
end

####################################
# Klass för variableltilldelningar #
####################################
class Tilldelning
  attr_accessor :name, :value, :operator
  def initialize(name, value = nil, op = nil)
    @name = name.name
    @value = value
    @operator = op
  end

  def eval()
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
        when '++'
          temp = Varde.new(@@nuvarande_scope.get_variable(@name).eval() + 1)
          puts temp if @@debug
        when '--'
          temp = Varde.new(@@nuvarande_scope.get_variable(@name).eval() - 1)
        end
        puts "KOM HITEN DÅ" if @@debug
        @@nuvarande_scope.change_variable(@name, temp)
        :ok
      end
    end
    :ok
  end
end

################### LOOPAR #########################

######################
# Klass för for-loop #
######################
class ForLoop
  attr_accessor :var_namn, :start, :slut, :satser
  def initialize(var_namn = nil,start,slut,satser)
    @var_namn = var_namn.name
    @start = start.eval()
    @slut = slut.eval()
    @satser = satser
  end

  def eval()
    @start.upto(@slut) do |i|      
      result = @satser.eval({@var_namn=>i})
      if result == "avbryt"
        return :ok
      end
    end
  end
end

########################
# Klass för while-loop #
########################
class MedansLoop
  attr_accessor :jamforelse, :satser
  def initialize(jamforelse, satser)
    @jamforelse = jamforelse
    @satser = satser
  end

  def eval()
    while @jamforelse.eval()
      result = @satser.eval()
      if result == "avbryt"
        return :ok
      end
    end
  end
end

################################################
# Denna klass används endast för att detektera #
# när en loop ska avbrytas.                    #
################################################
class AvbrytLoop
  def initialize()
  end

  def eval()
    # puts "Denna ska aldrig köras!!!"
  end
end

################ LISTOR #####################

####################
# Klass för listor #
####################
class Lista
  attr_accessor :array
  def initialize(value = [])
    @array = []
    if value != []
      1.upto(value.length) { |i|
        if value[i-1].class == Varde
          @array << value[i-1].eval()
        else
          @array << value[i-1]
        end
      }          
    else
      @array # Ska det se ut såhär Emil!!! :)
    end
  end

  def eval()
    @array
  end
end

#######################################
# Klass för parlistor (hash-tabeller) #
#######################################
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

###########################################################
# Klass för att lägga till element i listor och parlistor #
###########################################################
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

########################################################
# Klass för att ta bort element i listor och parlistor #
########################################################
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

####################################################
# Klass för att ändra värde i listor och parlistor #
####################################################
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

#######################################
# Klass för att deklarera en funktion #
#######################################
class FunktionsDeklarering
  attr_accessor :name, :satser, :params
  def initialize(name, satser, params = nil)
    @name = name
    @satser = satser
    @params = params
  end

  def eval()
    # Med denna teknik är det möjligt att lägga till funktioner i funktioner
    # Kanske ska det vara möjligt att göra det men skulle man vilja ta bort
    # den funktionaliteten så kan man bara kolla om previous_scope == nil
    # för att avgöra om man är på det globala scopet
    @@nuvarande_scope.add_variable(@name.name, [@params,@satser])
  end

end

#########################################
# Klass för parametrar till en funktion #
#########################################
class ParameterLista
  attr_accessor :params
  def initialize(params)
    @params = params
  end

  def eval()
    @params.each_index do |i|
      @params[i] = Varde.new(@params[i].eval())
    end
    return @params
  end
end

#####################################
# Klass som hanterar funktionsanrop #
#####################################
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
    
    #Kolla om argument och parametrar är angivna
    no_params = funk_params == nil or @args == nil
    
    # Kolla så att längderna på parametrar och argument stämmer
    if !no_params
      if funk_params.params.length != @args.params.length
        puts "MAJOR ERROR!!! Mismatch args and params when calling funktion: #{@name.name}"
      else
        0.upto(@args.params.length - 1) do |i|
          
          args_hash[funk_params.params[i].name] = @args.params[i].eval()
        end
      end
    end

    # Hämta satserna i funktionen
    f_satser = @@nuvarande_scope.get_variable(@name.name)[1].dup
    # Evaluera satserna och få tillbaka ett resultat
    retur_varde = f_satser.eval(args_hash)
    # Kolla om funktionen ska returnera något
    if retur_varde.class == Varde
      return retur_varde.eval()
    end
    return :ok
  end
end

#########################################################
# Klass för att returnera ett uttryck från en funktion. #
#########################################################
class Returnera
  attr_accessor :uttryck
  def initialize(uttryck)
    @uttryck = uttryck
  end

  def eval()
    return @uttryck.eval()
  end
end

############# SLUT PÅ FUNKTIONER #################
