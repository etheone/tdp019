# -*- coding: iso-8859-1 -*-


##################################
# Klass för att funktionen längd #
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
      puts "Funktionen .längd är inte tillgängligt typen #{temp}"
    end
  end
end

##########################################
# Klass för att ändra typ på en variabel #
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
        puts "Fel vid konvertering från INT till oklar typ"
      end
      
    elsif type == Float
      if @to == "till_heltal"
        temp = Varde.new(@@nuvarande_scope.get_variable(@name).eval().to_i)
        @@nuvarande_scope.change_variable(@name, temp)
      elsif @to == "till_strang"
        temp = Varde.new(@@nuvarande_scope.get_variable(@name).eval().to_s)
        @@nuvarande_scope.change_variable(@name, temp)
      else
        puts "Fel vid konvertering från flyttal till oklar typ"
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
        puts "Kan inte genomföra #{@to} på Array"
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
      puts "Det är inte möjligt att konvertera #{temp.class}"
    end    
  end
end

###################################
# Klass för att dela på en sträng #
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
      puts "\nFELMEDDELANDE: Det går ej att spränga/dela variabeln #{@name.upcase} pga att det är en #{temp.class.to_s.upcase}, denna funktionen fungerar endast med strängar."
    end
  end
end

#####################################
# Klass för funktionaliteten .klass #
#####################################
class HamtaKlass
  attr_accessor :name
  def initialize(name)
    @name = name
    @converter = {String => "Sträng", Fixnum => "Heltal", Float => "Flyttal", Array => "Lista", Hash => "ParLista"}
  end

  def eval()
    return @converter[@@nuvarande_scope.get_variable(@name).eval().class]
  end
end
