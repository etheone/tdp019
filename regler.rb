# -*- coding: utf-8 -*-
require './rdparse'
require './klasser'
require './startaNuLibrary'


class StartaNu
  
  def initialize(filnamn = nil)
    @fil = filnamn
    # Denna variabel används inte väl???????????????????
    #@@current_scope = Scope.new(nil)
    @startaNuParser = Parser.new("Starta Nu!") do
      
     
      token(/\n/) { |m| m} # Matcha nyradstecken
      token(/\s+/) # ignorera mellanslag
      token(/#.+/) # ignorera kommentarer

      
      token(/skapa metoden/) { |m| m }
      token(/inte är/)
      token(/lägg till/) { |m| m }
      token(/ta bort/) { |m| m }
      token(/för varje/) { |m| m }
      token(/-?\d+\.\d+/) { |flyttal| puts "Hitta ett flyttal"; flyttal.to_f } #Matcha flyttal
      token(/-?\d+/) { |heltal| heltal.to_i } # Matcha heltal
      #token(/\".+\"/) { |m| m} # Matcha strängar
      token(/\"[^\"]+\"/) { |m| m } # Ett nytt test att matcha strängar
      token(/[=<>!\+\-\*\/]=/) { |m| m }
      token(/startaNu/) { |m| m }
      token(/slutaNu/) { |m| m }
      token(/[\wåäöÅÄÖ]+/) { |m| m } # Matcha ord
      token(/./) { |m| m } # Matcha tecken
      
      start :program do

        match("startaNu",:nyrad,:satser,"slutaNu") {|_,_,satser,_| Satser.new(satser)}
        match(:satser) {|satser| Satser.new(satser)} # För tester och i interpretatorn
      end

      rule :satser do
        match(:sats) {|sats| sats}
        match(:satser, :sats) do |satser,sats|
          satser += sats
          satser
        end
      end

      rule :sats do
        match(:loop) { |loop| [loop]}
        match(:om) { |om| [om] }
        match(:skriv) {|skriv| [skriv]}
        match(:funktion) { |funktion| [funktion] }
        match(:funktionsanrop) #call?
        match(:deklarering) { |deklarering| [deklarering] }
        match(:tilldelning) { |tilldelning| [tilldelning] }
        match(:nyrad) {|nyrad| [nyrad]}
      end

      rule :loop do
        match(:for)
        match(:medans)
      end


      ############# UTRSKRIFT ###############

      rule :skriv do
        # Matchar till en början bara utskrift av en sträng
       # match('skriv', :strang, "+", :identifierare) {|_, skriv, _, var| SkrivUt.new(skriv) }
        match('skriv', :uttry) { |_, att_skriva_ut| SkrivUt.new(att_skriva_ut) }
        match('skriv', :strang) { |_, skriv|
          SkrivUt.new(skriv) }
      end

      ############ SLUT PÅ UTSKRIFT ##################

      #################### LOOPS #####################
      rule :for do
        match("för varje", :identifierare, "i", :identifierare, :nyrad, "start", :nyrad, :satser, "slut") { | _, iterator, _, list_name, _, _, _, satser, _ | ListLoop.new(list_name, Satser.new(satser),iterator) }
        match("för varje", :identifierare, ",", :identifierare, "i", :identifierare, :nyrad, "start", :nyrad, :satser, "slut") { | _, iterator1,_, iterator2, _, list_name, _, _, _,satser, _ | ListLoop.new(list_name, Satser.new(satser), iterator1, iterator2) }
        match("för", :identifierare, :heltal, "till", :heltal, :nyrad, "start", :nyrad,
              :satser, "slut") { |_,var_namn,start,_,slut,_,_,_,satser,_|
          ForLoop.new(var_namn,start,slut,Satser.new(satser))}
        match("för", :heltal, "till", :heltal, :nyrad, "start", :nyrad,
              :satser, "slut") { |_,start,_,slut,_,_,_,satser,_|
          ForLoop.new(start,slut,Satser.new(satser))}
      end

      rule :medans do
        match("medans", :logiskt_uttryck, :nyrad, "start", :nyrad, :satser, "slut") { |_, jamforelse,
          _,_,_,satser,_ | MedansLoop.new(jamforelse, Satser.new(satser)) }
      end

      ############## SLUT PÅ LOOPS ##################

      ############## START PÅ OM ###################
      

      rule :om do
        match("om", :logiskt_uttryck, :nyrad, "start", :nyrad, :satser, "slut") { |_, l_ut, _, _, _,
          satser, _| Om.new(l_ut, Satser.new(satser)) }
        match("om", :logiskt_uttryck, :nyrad, "start", :nyrad, :satser, :annars_kropp, "slut") { |_, l_ut, _,
          _, _, satser, annars_kropp, _ | Om.new(l_ut, Satser.new(satser), annars_kropp) }
        #todo match annars om? *************************************************************
      end

      rule :annars_kropp do
        match("annars", :satser) { |_,satser| Satser.new(satser) }
      end

      ############# SLUT PÅ OM ####################

      ###################### Deklarering / tilldelning #######
      rule :deklarering do
        match(:lista)
        match("skapa",:identifierare,"=",:uttry) { |_, name, _, value| Deklarering.new(name,value) }
        match("skapa",:identifierare) { |_, name| Deklarering.new(name) }
      end

      rule :tilldelning do
        match(:snabbtilldelning)
        match("lägg till", :aritm_uttryck, :identifierare) { |_,to_add,list_name| LaggTillILista.new(list_name, to_add ) }
        match("lägg till", :aritm_uttryck, ",", :listitem, :identifierare) { |_,to_add,_,more_to_add,list_name| LaggTillILista.new(list_name, to_add, nil, more_to_add ) }
        match("lägg till", :varde, ":", :varde, ",", :parlistitem, :identifierare) { |_,key_to_add, _,
          value_to_add, _,more_to_add, list_name | LaggTillILista.new(list_name, value_to_add, key_to_add, more_to_add) }
        match("lägg till", :varde, ":", :varde, :identifierare) { |_, key_to_add, _, value_to_add, list_name | LaggTillILista.new(list_name, value_to_add, key_to_add) }
        match(:identifierare,"=",:uttry) { |name, _, value| Tilldelning.new(name, value) }
      end

      rule :snabbtilldelning do
        match(:identifierare, "+=", :uttry) {|name,op,value| Tilldelning.new(name, value, op) }
        match(:identifierare, "-=", :uttry) {|name,op,value| Tilldelning.new(name, value, op) }
        match(:identifierare, "*=", :uttry) {|name,op,value| Tilldelning.new(name, value, op) }
        match(:identifierare, "/=", :uttry) {|name,op,value| Tilldelning.new(name, value, op) }
      end


      ################# FUNKTIONER #########################
      
      rule :funktion do        
        match("skapa metoden", :identifierare, :parameter_lista_deklarering, :nyrad, "start", :satser, "slut") {
          |_, name, params, _, _, satser, _|
          FunktionsDeklarering.new(name, Satser.new(satser), ParameterLista.new(params))
        }
        match("skapa metoden", :identifierare, :nyrad, "start", :satser, "slut") { |_, name, _, _, satser, _|
          FunktionsDeklarering.new(name, Satser.new(satser)) }
        match(:funktionsanrop)
      end

      rule :funktionsanrop do
        match("kör", :identifierare, "med", :parameter_lista_anrop) { | _, name, _, args|
          FunktionsAnrop.new(name, ParameterLista.new(args)) }
        match("kör", :identifierare) { |_, name|
          FunktionsAnrop.new(name) }
        match(:builtinfuncs)
      end
      
      rule :parameter_lista_deklarering do
        match(:identifierare) { |ident| [ident] }
        match(:parameter_lista_deklarering, ',', :identifierare) { |params,_,param|
          params += [param]
          params
        }
      end

      rule :parameter_lista_anrop do
        match(:varde) { |varde| [varde]}
        match(:parameter_lista_anrop, ",", :varde) { |args, _, arg|
          args += [arg]
          args
        }      
      end

      rule :builtinfuncs do
        match(:identifierare, ".", "längd") { |var, _, _| LengthFunc.new(var.name) }
        match(:identifierare, ".", "storlek") { |var, _, _| LengthFunc.new(var.name) }
        match(:identifierare, ".", "spräng", "(", :strang, ")") { |var, _, _, _,delim,_|
          DelaStrang.new(var.name, delim) }
        match(:identifierare, ".", "spräng") { |var, _, _,| DelaStrang.new(var.name) }
        match(:identifierare, ".", "till_strang") {  |var, _, strang| AndraTyp.new(var.name, strang) }
        match(:identifierare, ".", "till_heltal") { |var, _, strang|  AndraTyp.new(var.name, strang) }
        match(:identifierare, ".", "till_flyttal") { |var, _, strang| AndraTyp.new(var.name, strang) }
        match(:identifierare, ".", "klass") { |var, _, _| GetKlass.new(var.name)  }
        
      end

      ####################### SLUT PÅ FUNKTIONER #################

      ##################### BEHÅLLARE ############################3

      rule :lista do
        match("skapa",:identifierare, "ParLista", "=", :parlistitem) { |_, name, _, _, items| Deklarering.new(name, ParLista.new(items) ) }
        match("skapa",:identifierare, "Lista", "=", :listitem) { |_, name, _, _, items| Deklarering.new(name, Lista.new(items) ) }

        match("skapa",:identifierare, "Lista") { |_,name,_| Deklarering.new(name, Lista.new()) }
        match("skapa",:identifierare, "ParLista") { |_, name, _, _, items| Deklarering.new(name, ParLista.new() ) }
        match("ta bort", :aritm_uttryck, :identifierare) { |_, value, list_name| TaBortVardeILista.new(list_name, value) }
        
        match(:identifierare, "[", :aritm_uttryck, "]", "=", :listitem) { |list_name, _, value, _, _, new_value | AndraVardeILista.new(list_name, value, new_value) }
      end

      rule :listitem do
        match(:aritm_uttryck) {| a | [a]}
        match(:listitem, ",", :aritm_uttryck) do |items, _, item|
          items += [item]
          items
        end
      end

      rule :parlistitem do
        match(:varde, ":", :varde) { | key, _, value | Hash[key, value] }
        match(:parlistitem, ",", :varde, ":", :varde) do |items=Hash.new, _, key, _, value |
          items[key] = value
          items
        end
      end

      ################### SLUT PÅ BEHÅLLARE #####################
              
      rule :uttry do
        match(:logiskt_uttryck)
        match(:aritm_uttryck)
        match(:identifierare)
      end
      
      rule :identifierare do
        match(/[a-zA-Z0-9]+/) {|name| Variabel.new(name) }
      end

      rule :logiskt_uttryck do
        match(:logiskt_uttryck, :logisk_operator, :logiskt_uttryck) { |uttr1, op, uttr2|
          LogisktUttryck.new(uttr1, LogiskOperator.new(op), uttr2) }
        match(:jamforelse, :jamf_operator, :jamforelse) { |u1,op,u2|
          Jamforelse.new(u1, JamfOperator.new(op), u2) }
      end

      rule :jamforelse do
        match(:aritm_uttryck)
      end

      rule :logisk_operator do
        match("och") 
        match("eller")
        match("inte är") # Denna funkar inte, är inte implementerad
      end

      rule :jamf_operator do
        match("<")
        match(">")
        match(">=")
        match("<=")
        match("==")
        match("!=")
      end

      rule :nyrad do
        match("\n") {|_| NyRad.new()}
      end

      rule :aritm_uttryck do
        match(:term, "+", :aritm_uttryck) { |term1,_,term2| AritmUttryck.new(term1,AritmOperator.new('+'),term2) }
        match(:aritm_uttryck, "-", :term) { |term1,_,term2| AritmUttryck.new(term1,AritmOperator.new('-'),term2) }
        match(:term) #{ |t| t }
      end

      rule :term do
        match(:term, "*", :faktor) { |term1,_,term2| AritmUttryck.new(term1,AritmOperator.new('*'),term2)}
        match(:term, "/", :faktor) { |term1,_,term2| AritmUttryck.new(term1,AritmOperator.new('/'),term2)}
        match(:term, "^", :faktor) { |term1,_,term2| AritmUttryck.new(term1,AritmOperator.new('^'),term2)}
        match(:term, "%", :faktor) { |term1,_,term2| AritmUttryck.new(term1,AritmOperator.new('%'),term2)}
        match(:faktor) #{ |faktor| faktor }
        #{ |termm, _, faktor| termm * faktor }
      end

      rule :faktor do
        match("(", :aritm_uttryck, ")")  { |_, uttryck, _| uttryck }
        match(:varde) #{ |varde| varde }
        # match(variabel)
      end

      rule :varde do
        match(:bool)
        match(:heltal)
        match(:flyttal)
        match(:strang)
      end

      rule :bool do
        match("sant")
        match("falskt")
      end

      rule :heltal do
        match(Integer) { |heltal| Varde.new(heltal) }
      end

      rule :flyttal do
        match(Float) { |flyttal| Varde.new(flyttal) }
      end

      rule :strang do
        match(/\".+\"/) { |strang| Varde.new(strang[1..-2]) }
        match(:identifierare)
      end
    end
  end    

  ######################## END OF BNF ##########################
  def done(str)
    ["quit","exit","bye",""].include?(str.chomp)
  end
  
  def run(interactive = false)
    #log false
    if interactive
      #return @startaNuParser.parse yield
      @startaNuParser.logger.level = Logger::WARN
      result = @startaNuParser.parse yield
      result.eval
      return
    end
    print "StartaNu >>> "
    str = gets
    if done(str) then
      puts "Bye."
    else
      puts "=> #{@startaNuParser.parse str}"
      #puts "Aktuella variabler: #{@@variables}"
      run
    end
  end

  def start
    f = File.read(@fil)
    log false
    result = @startaNuParser.parse f
    result.eval
    puts "Worked like a charm!"
  end

  def log(state = true)
    if state
      @startaNuParser.logger.level = Logger::DEBUG
    else
      @startaNuParser.logger.level = Logger::WARN
    end
  end
end


# Testkörningar
#=begin
sn = StartaNu.new

sn.run(true){'
skriv "Första raden"
skapa lista Lista = 1, 2, 3, 4, 50, 100
skriv lista
för varje nummer i lista
start
  skriv "Kom igen"
  skriv nummer
slut

skapa plista ParLista = "okej":5, "apa":4, "hej":3
skriv plista
för varje k, v i plista
start
  skriv "Inne i för varje plista"
  skriv k
  skriv v
slut

skapa namnet = " emil"
skriv "hej jag heter" + namnet

skapa tjena = 2
skriv tjena
tjena +=2
skriv tjena

tjena *=4
skriv tjena

skapa tja ParLista = "hoj":"lol"
skriv tja
lägg till "hej":5 tja
skriv "........"
skriv tja
skriv "......."
ta bort "hej" tja
skriv tja

skapa a = 5
skriv "**********"
skriv a
skriv "**********"

skapa grejjen = 5
skapa metoden test var1, var2
start
  skriv var1
  skriv var2
  om var2 < 7
  start
  kör test med "tjena", 8
  skriv "Det funka!"
  slut

slut

skapa summa = 0
för i 1 till 5
start
  skriv "summa plus summa"
  summa = summa + i
slut
skriv summa

kör test med "hej", 2

skapa i = 0
medans i < 10
start
skriv i
i += 1
slut

skapa arraysen Lista = 5,6,7,8
skriv arraysen
arraysen.längd

skapa parraysen ParLista = "hej":5
skriv parraysen
parraysen.längd

skapa numren = 5
skriv numren
numren.till_flyttal
skriv numren

skriv "          "


skapa numrete = 5.0
skriv numrete
numrete.till_heltal
skriv numrete
skriv "             "
skapa enString = "hejsan123"
enString.klass
enString.till_heltal
skriv enString
enString.klass
skriv "             "
skapa ettFlyt = 5.0
skriv ettFlyt
ettFlyt.till_strang
skriv ettFlyt
ettFlyt.klass
skriv "             "
skapa ettHel = 10
ettHel.klass
skriv ettHel
ettHel.till_strang
skriv ettHel
ettHel.klass
skriv "            "
arraysen.till_strang
skriv arraysen
arraysen.klass

skapa minStrang = "Hejsan jag heter Emil och studerar ibland"
minStrang.spräng
skriv minStrang
minStrang.klass

skriv "           "
skapa minStreng = "56awd3.56awd4"
minStreng.till_flyttal
skriv minStreng
minStreng.klass

skapa varen1 = 5
skapa varen2 = 10

skapa efternamn = "nilsson"

skriv "hej " + 10+3

skapa kanonvariabeln = "tjenare " + varen2
skriv kanonvariabeln
skriv "tjenare mannen " + varen2
'}

=begin
skapa hej = 5


medans hej < 8
start
skriv "medans loop"
hej = hej + 1
slut
=end
