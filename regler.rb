# -*- coding: utf-8 -*-
require './rdparse'
require './klasser'
require './startaNuLibrary'

#############
# regler.rb #
#############


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
      token(/\+{2}|\-{2}/) { |m| m }
      token(/[=<>!\+\-*\ru\/]=/) { |m| m }
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
        match('skriv', :builtinfuncs) { |_, att_skriva_ut| SkrivUt.new(att_skriva_ut) }
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
        match(:identifierare, "++") {|name,op | Tilldelning.new(name, nil, op) }
        match(:identifierare, "--") {|name,op | Tilldelning.new(name, nil, op) }
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
        match(:identifierare, ".", "längd") { |var, _, _| HamtaLangd.new(var.name) }
        match(:identifierare, ".", "storlek") { |var, _, _| HamtaLangd.new(var.name) }
        match(:identifierare, ".", "spräng", "(", :strang, ")") { |var, _, _, _,delim,_|
          DelaStrang.new(var.name, delim) }
        match(:identifierare, ".", "dela", "(", :strang, ")") { |var, _, _, _,delim,_|
          DelaStrang.new(var.name, delim) }
        match(:identifierare, ".", "spräng") { |var, _, _,| DelaStrang.new(var.name) }
        match(:identifierare, ".", "dela") { |var, _, _,| DelaStrang.new(var.name) }
        match(:identifierare, ".", "till_strang") {  |var, _, strang| AndraTyp.new(var.name, strang) }
        match(:identifierare, ".", "till_heltal") { |var, _, strang|  AndraTyp.new(var.name, strang) }
        match(:identifierare, ".", "till_flyttal") { |var, _, strang| AndraTyp.new(var.name, strang) }
        match(:identifierare, ".", "klass") { |var, _, _| HamtaKlass.new(var.name)  }
        
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
        match(:parlistitem, ",", :varde, ":", :varde) do | items, _, key, _, value |
          items = Hash.new
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
        match(:builtinfuncs)
        match(:aritm_uttryck)
      end

      rule :logisk_operator do
        match("och") 
        match("eller")
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
      begin
        @startaNuParser.logger.level = Logger::WARN
        result = @startaNuParser.parse yield
        result.eval
      rescue Exception => msg
        puts "Du har skrivit fel syntax \n(#{msg.message})"
      end
	return
    end
    print "StartaNu >>> "
    str = gets
    if done(str) then
      puts "Bye."
    else
      result = @startaNuParser.parse str
      print "=> "
      result.eval
      run
    end
  end


  def start
    f = File.read(@fil)
    log false
    begin
      result = @startaNuParser.parse f
      result.eval
    rescue Exception => msg
      puts "Problem with syntax"
    end
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
if __FILE__ == $0
    sn = StartaNu.new
    
    sn.run(true){'
skriv "hej"
skapa h = 3
skriv h.klass
om h.klass == "Heltal"
start
skriv h
slut

om 3 * 5 > 10
start
  skriv "15 är större än 10!!!"
slut
'}
end
