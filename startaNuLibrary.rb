# -*- coding: iso-8859-1 -*-


##################################
# Klass f�r att funktionen l�ngd #
##################################
class HamtaLangd
  attr_accessor :name
  def initialize(name)
    @name = name
  end

  def eval()
    if @@nuvarande_scope.get_variable(@name).eval().class == String ||
        @@nuvarande_scope.get_variable(@name).eval().class == Array ||
        @@nuvarande_scope.get_variable(@name).eval().class == Hash
      return @@nuvarande_scope.get_variable(@name).eval().length
    else
      temp = @@nuvarande_scope.get_variable(@name).eval().class.to_s.upcase
      puts "Funktionen .l�ngd �r inte tillg�ngligt typen #{temp}"
    end
  end
end

##########################################
# Klass f�r att �ndra typ p� en variabel #
##########################################
class AndraTyp
  attr_accessor :name, :to
  def initialize(name, to)
    @name = name
    @to = to
  end

  def eval()
    type = @@nuvarande_scope.get_variable(@name).eval().class
    if type == Fixnum
      if @to == "till_flyttal"
        temp = Varde.new(@@nuvarande_scope.get_variable(@name).eval().to_f)
        @@nuvarande_scope.change_variable(@name, temp)
      elsif @to == "till_strang"
        temp = Varde.new(@@nuvarande_scope.get_variable(@name).eval().to_s)
        @@nuvarande_scope.change_variable(@name, temp)
      else
        puts "Fel vid konvertering fr�n INT till oklar typ"
      end
      
    elsif type == Float
      if @to == "till_heltal"
        temp = Varde.new(@@nuvarande_scope.get_variable(@name).eval().to_i)
        @@nuvarande_scope.change_variable(@name, temp)
      elsif @to == "till_strang"
        temp = Varde.new(@@nuvarande_scope.get_variable(@name).eval().to_s)
        @@nuvarande_scope.change_variable(@name, temp)
      else
        puts "Fel vid konvertering fr�n flyttal till oklar typ"
      end
      
    elsif type == Array
      if @to == "till_strang"
        array = @@nuvarande_scope.get_variable(@name).eval()
        tempString = ""
        array.each_index do |pos|
          tempString += array[pos].to_s
          if pos != array.length - 1
            tempString += " "
          end
        end
        @@nuvarande_scope.change_variable(@name, Varde.new(tempString))
      else
        puts "Kan inte genomf�ra #{@to} p� Array"
      end
    
    elsif type == String
      if @to == "till_heltal"
        tempString = @@nuvarande_scope.get_variable(@name).eval()
        tempInt = tempString.gsub(/[^0-9]/, '').to_i
        temp = Varde.new(tempInt)
        @@nuvarande_scope.change_variable(@name, temp)
      elsif @to == "till_flyttal"
        tempString = @@nuvarande_scope.get_variable(@name).eval()
        tempFloat = tempString.gsub(/[^0-9\.0-9]/, '').to_f
        temp = Varde.new(tempFloat)
        @@nuvarande_scope.change_variable(@name, temp)
      else
        puts "Massive ERROR"
      end
    else
      puts "Det �r inte m�jligt att konvertera #{temp.class}"
    end    
  end
end

###################################
# Klass f�r att dela p� en str�ng #
###################################
class DelaStrang
  attr_accessor :name, :delim
  def initialize(name, delim = nil)
    @name = name
    @delim = delim
  end

  def eval()
    temp = @@nuvarande_scope.get_variable(@name).eval()
    if temp.class == String
      if @delim == nil
        tempArray = temp.split
        @@nuvarande_scope.change_variable(@name, Lista.new(tempArray))
      else
        tempArray = temp.split(@delim.eval)
        @@nuvarande_scope.change_variable(@name, Lista.new(tempArray))
      end
    else
      puts "\nFELMEDDELANDE: Det g�r ej att spr�nga/dela variabeln #{@name.upcase} pga att det �r en #{temp.class.to_s.upcase}, denna funktionen fungerar endast med str�ngar."
    end
  end
end

#####################################
# Klass f�r funktionaliteten .klass #
#####################################
class HamtaKlass
  attr_accessor :name
  def initialize(name)
    @name = name
    @converter = {String => "Str�ng", Fixnum => "Heltal", Float => "Flyttal", Array => "Lista", Hash => "ParLista"}
  end

  def eval()
    return @converter[@@nuvarande_scope.get_variable(@name).eval().class]
  end
end
