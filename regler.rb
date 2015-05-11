# -*- coding: utf-8 -*-
require './rdparse'
require './klasser'
require './startaNuLibrary'

######################################################################
# Denna fil är inte uppkommenterad till 100% än    .                 #
# I slutet av filen finns det ett antal tester på språket i nuläget. #
######################################################################


class StartaNu
  
  def initialize(filnamn = nil)
    @fil = filnamn

    @startaNuParser = Parser.new("Starta Nu!") do
      
     
      token(/\n/) { |m| m} # Matcha nyradstecken
      token(/\s+/) # ignorera mellanslag
      token(/#.+/) # ignorera kommentarer

      
      token(/skapa metoden/) { |m| m }
      token(/inte är/)
      token(/lägg till/) { |m| m }
      token(/ta bort/) { |m| m }
      token(/för varje/) { |m| m }
      token(/avbryt loop/) { |m| m }
      token(/-?\d+\.\d+/) { |flyttal| flyttal.to_f } #Matcha flyttal
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
        match(:deklarering) { |deklarering| [deklarering] }
        match(:funktion) { |funktion| [funktion] }
        match(:funktionsanrop) { |f_anrop| [f_anrop] } # Nytillagt, kanske ska tas bort?
        match(:tilldelning) { |tilldelning| [tilldelning] }
        match(:nyrad) {|nyrad| [nyrad]}
      end

      rule :loop do
        match(:for)
        match(:medans)
        match(:avbryt_loop)
      end


      ############# UTRSKRIFT ###############

      rule :skriv do
        match('skriv', :uttry) { |_, att_skriva_ut| SkrivUt.new(att_skriva_ut) }
      end

      ############ SLUT PÅ UTSKRIFT ##################

      #################### LOOPS #####################
      rule :for do
        match("för varje", :identifierare, "i", :identifierare, :nyrad, "start", :nyrad, :satser, "slut") { | _, iterator, _, list_name, _, _, _, satser, _ | ListLoop.new(list_name, Satser.new(satser),iterator) }
        match("för varje", :identifierare, ",", :identifierare, "i", :identifierare, :nyrad, "start", :nyrad, :satser, "slut") { | _, iterator1,_, iterator2, _, list_name, _, _, _,satser, _ | ListLoop.new(list_name, Satser.new(satser), iterator1, iterator2) }
        match("för", :identifierare, :heltal, "till", :heltal, :nyrad, "start", :nyrad,
              :satser, "slut") { |_,var_namn,start,_,slut,_,_,_,satser,_|
          ForLoop.new(var_namn,start,slut,Satser.new(satser))}
        #match("för", :heltal, "till", :heltal, :nyrad, "start", :nyrad, ###############
        #      :satser, "slut") { |_,start,_,slut,_,_,_,satser,_| ###################### BORTTAGET!!!!!!!
        #  ForLoop.new(start,slut,Satser.new(satser))} #################################
      end

      rule :medans do
        match("medans", :logiskt_uttryck, :nyrad, "start", :nyrad, :satser, "slut") { |_, jamforelse,
          _,_,_,satser,_ | MedansLoop.new(jamforelse, Satser.new(satser)) }
      end

      rule :avbryt_loop do
        match("avbryt loop") { |_| AvbrytLoop.new() }
      end
      ############## SLUT PÅ LOOPS ##################

      ############## START PÅ OM ###################
      

      rule :om do
        match("om", :logiskt_uttryck, :nyrad, "start", :nyrad, :satser, "slut") { |_, l_ut, _, _, _,
          satser, _| Om.new(l_ut, Satser.new(satser)) }
        match("om", :logiskt_uttryck, :nyrad, "start", :nyrad, :satser, :annars_kropp, "slut") { |_, l_ut, _,
          _, _, satser, annars_kropp, _ | Om.new(l_ut, Satser.new(satser), annars_kropp) }
      end

      rule :annars_kropp do
        match("annars", :satser) { |_,satser| Satser.new(satser) }
      end

      ############# SLUT PÅ OM ####################

      ###################### Deklarering / tilldelning #######
      rule :deklarering do
        match(:lista)
        match("skapa",:identifierare,"=",:funktionsanrop) { |_, name,_,value| Deklarering.new(name, value) }
        match("skapa",:identifierare,"=",:uttry) { |_, name, _, value| Deklarering.new(name,value) }
        match("skapa",:identifierare) { |_, name| Deklarering.new(name) }
      end

      rule :tilldelning do
        match(:identifierare,"=",:funktionsanrop) { |name,_,value| Tilldelning.new(name, value) }
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
        match("returnera", :uttry) { |_, uttryck| Returnera.new(uttryck) }
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
        match(:uttry) { |varde| [varde]}
        match(:parameter_lista_anrop, ",", :uttry) { |args, _, arg|
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
        match(:term)
      end

      rule :term do
        match(:term, "*", :faktor) { |term1,_,term2| AritmUttryck.new(term1,AritmOperator.new('*'),term2)}
        match(:term, "/", :faktor) { |term1,_,term2| AritmUttryck.new(term1,AritmOperator.new('/'),term2)}
        match(:term, "^", :faktor) { |term1,_,term2| AritmUttryck.new(term1,AritmOperator.new('^'),term2)}
        match(:term, "%", :faktor) { |term1,_,term2| AritmUttryck.new(term1,AritmOperator.new('%'),term2)}
        match(:faktor) 
      end

      rule :faktor do
        match("(", :aritm_uttryck, ")")  { |_, uttryck, _| uttryck }
        match(:varde)
      end

      rule :varde do
        match(:bool)
        match(:heltal)
        match(:flyttal)
        match(:strang)
      end

      rule :bool do
        match("sant") { |_| Varde.new(true) }
        match("falskt") { |_| Varde.new(false) }
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

  ######################## END OF RULES ##########################
  
  def done(str)
    ["quit","exit","bye",""].include?(str.chomp)
  end
  
  def run(interactive = false)
    log false
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
      #puts "=> #{@startaNuParser.parse str}"
      result = @startaNuParser.parse str
      print "=> "
      result.eval
      run
    end
  end

  def start
    f = File.read(@fil)
    log false
    result = @startaNuParser.parse f
    result.eval
    #puts "Worked like a charm!"
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
if __FILE__ == $0
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

skapa na = "Na är natrium"

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

skapa metoden retur_test
start
  skriv "Inne i metoden retur_test"
  returnera 1 + 10
  skriv "Det här borde inte vara med"
slut

skapa var_retur_test = kör retur_test
#var_retur_test = kör retur_test
skriv var_retur_test
skriv "Ändra värde på var_retur_test till 50 + 25:"
var_retur_test = 50 + 25
skriv var_retur_test

skapa metoden retur_test2 var1
start
  skriv "Inne i metoden retur_test2"
  skriv "var1 är: " + var1
  returnera var1 + 30
slut

skapa var_retur_test2 = kör retur_test2 med 5
skriv var_retur_test2
skriv "var_retur_test2 borde vara 35 och är: " + var_retur_test2

skapa metoden fib n
start
  skriv "**** Det n som kommer in till fib är: " + n
  om n == 1 eller n == 2
  start
    returnera 1
  annars
    skriv "I annars är n: " + n
    n = n - 1
    skriv "I annars efter neg är n: " + n
    skapa del1 = kör fib med n
    skriv "del1 är: " + del1

    n -= 1
    skapa del2 = kör fib med n
    skriv "del2 är: " + del2

    returnera del1 + del2
  slut
slut

skriv " "
skriv "Fibonacci tester"
skapa first = kör fib med 1
skriv "Det första: " + first
#skapa second = kör fib med 2
#skriv second
skapa third = kör fib med 3
skriv "Det tredje: " + third
#skapa fourth = kör fib med 4
#skriv fourth
#skapa fifth = kör fib med 5
#skriv fifth
skapa sixth = kör fib med 6
skriv "Det sjätte: " + sixth

# Testar att avbryta en för-loop
för i 0 till 10
start
  skriv i
  om i == 5
  start
    skriv "Här ska det avbrytas"
    avbryt loop
  slut
slut

# Testar att avbryta en medans-loop
skapa asd = 0
medans 1 == 1
start
  skriv "Again and again..."
  asd += 1
  om asd == 10
  start
    avbryt loop
  slut
slut

skapa booltest = sant
skapa booltest2 = falskt
skriv booltest
skriv booltest2
om booltest == sant och booltest2 == falskt
start
  skriv "Det här ska skrivas ut"
slut
skapa booltest3 = booltest == sant och booltest2 == sant
skriv "Borde vara falskt: " + booltest3

skriv "En enkel sträng"
'}
end

=begin
skapa hej = 5


medans hej < 8
start
skriv "medans loop"
hej = hej + 1
slut
=end
