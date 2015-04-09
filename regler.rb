# -*- coding: utf-8 -*-
require './rdparse'
require './klasser'


class StartaNu
  
  def initialize(filnamn = nil)
    @fil = filnamn
    @@current_scope = Scope.new(nil)
    @startaNuParser = Parser.new("Starta Nu!") do
      
     
      token(/\n/) { |m| m} # Matcha nyradstecken
      token(/\s+/) # ignorera mellanslag
      token(/#.+/) # ignorera kommentarer

      
      token(/skapa metoden/)
      token(/inte är/)
      token(/-?\d+\.\d+/) { |flyttal| puts "Hitta ett flyttal"; flyttal.to_f } #Matcha flyttal
      token(/-?\d+/) { |heltal| heltal.to_i } # Matcha heltal
      #token(/\".+\"/) { |m| m} # Matcha strängar
      token(/\"[^\"]+\"/) { |m| m } # Ett nytt test att matcha strängar
      token(/==/) { |m| m }
      token(/<=/) { |m| m }
      token(/>=/) { |m| m }
      token(/!=/) { |m| m }
      token(/startaNu/) { |m| m }
      token(/slutaNu/) { |m| m }
      token(/[\wåäöÅÄÖ]+/) { |m| m } # Matcha ord
      token(/./) { |m| m } # Matcha tecken

      start :program do
        #match(:assign)
        #match(:expr)
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
        #match(:funktion)
        match(:deklarering) { |deklarering| [deklarering] }
        match(:tilldelning) { |tilldelning| [tilldelning] }  
        match(:nyrad) {|nyrad| [nyrad]}
      end

      rule :loop do
        match("för", :identifierare, :heltal, "till", :heltal, :nyrad, "start", :nyrad, :satser, "slut") { |_,var_namn,start,_,slut,_,_,_,satser,_| ForLoop.new(var_namn,start,slut,Satser.new(satser))}
        match("medans", :jamforelse, :nyrad, "start", :nyrad, :satser, "slut") { |_, jamforelse,_,_,_,satser,_ | MedansLoop.new(jamforelse, Satser.new(satser))}
      end

      rule :om do
        match("om", :logiskt_uttryck, :nyrad, "start", :nyrad, :satser, "slut") { |_, l_ut, _, _, _, satser, _| Om.new(l_ut, Satser.new(satser)) }
        match("om", :logiskt_uttryck, :nyrad, "start", :nyrad, :satser, :annars_kropp, "slut") { |_, l_ut, _, _, _, satser, annars_kropp, _ | Om.new(l_ut, Satser.new(satser), annars_kropp) }
      end

      rule :annars_kropp do
        match("annars", :satser) { |_,satser| Satser.new(satser) }
      end

      ###################### Variabeldeklarering / tilldelning #######
      rule :deklarering do
        match("skapa",:identifierare,"=",:uttryck) { |_, name, _, value| Deklarering.new(name,value) }
        match("skapa",:identifierare) { |_, name| Deklarering.new(name) }
      end

      rule :tilldelning do
        match(:identifierare,"=",:uttryck) { |name, _, value| Tilldelning.new(name, value) }

      end

      rule :funktion do
        match("skapa metoden", :identifierare, :parameter_lista, :nyrad, "start", :nyrad, :satser, "slut")
        match("skapa metoden", :identifierare, :nyrad, :satser, "slut")
      end
      
      rule :parameter_lista do
        match(:identifierare, ",", :parameter_lista)
        match(:identifierare)
      end

      rule :uttryck do      
        match(:logiskt_uttryck) # Kanske ska vara här, borttaget pga stack level to deep
        match(:aritm_uttryck) 
        match(:identifierare) 
        #match(:f_anrop)
      end
      

      rule :identifierare do
        #match(:variabel)
        match(:name)
      end

      # Här är det nog lite fel..........
      rule :logiskt_uttryck do
        #match(:jamforelse)
        match(:logiskt_uttryck, :logisk_operator, :logiskt_uttryck) { |uttr1, op, uttr2| LogisktUttryck.new(uttr1, LogiskOperator.new(op), uttr2) }
        match(:jamforelse)

      end

      rule :logisk_operator do
        match("och") 
        match("eller")
        match("inte är") # Denna funkar inte, är inte implementerad
      end
      
      rule :jamforelse do
        match(:uttryck, :jamf_operator, :uttryck) { |u1,op,u2| Jamforelse.new(u1, JamfOperator.new(op), u2) }
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
        match(:faktor) #{ |faktor| faktor }
        #{ |termm, _, faktor| termm * faktor }
      end

      rule :faktor do
        match("(", :aritm_uttryck, ")") #{ |_, uttryck, _| uttryck }
        match(:varde) #{ |varde| varde }
        # match(variabel)
      end

      rule :varde do
        match(:bool)
        match(:heltal)
        match(:flyttal)
        match(:strang)
        
        #match(Integer) { |int| int }
        #match(:varde,:siffra) { |varde, siffra| puts "In rule :varde"}
        #match("-", :varde) { |_, varde| varde * (-1)}
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
      end

      ####################### Skriv / print #############
      rule :skriv do
        # Matchar till en början bara utskrift av en sträng
        match('skriv', :strang) { |_, skriv|
          SkrivUt.new(skriv) }
        match('skriv', :uttryck) { |_, att_skriva_ut| SkrivUt.new(att_skriva_ut) }
      end
      ###################### Slut skriv / print ########

      rule :name do
        match(/[\wåäöÅÄÖ]+/) {|name| name }
      end
    end
  end    
  
  def done(str)
    ["quit","exit","bye",""].include?(str.chomp)
  end
  
  def run(interactive = false)
#    log false
    if interactive
      #return @startaNuParser.parse yield
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
      puts "Aktuella variabler: #{@@variables}"
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
#skapa hej = 5

om 5 > 1
start
skriv "hehehehehehe"
slut
'}
=begin
sn.run(true){'



skapa hej = 4
för i 5 till 10
start
skriv hej

slut
'}
=end
=begin
sn.run(true) {'skriv "hej world"

skriv "massa"
skapa hej = 5
skapa tjena
tjena = "Vad säger du nu då"
skriv hej

om 1 == 1
start
skapa tja = 10
skriv "Vi testar"
slut
skriv "Vi testar efter att ett scope har avslutats"


#456 + 3
#"ska vi leka" + " nu?"

4 * 3 + 10
skriv "Testar 5 == 5"
5 == 5
skriv "Testar 0 == 1"
0 == 1

skriv "Testar 1 <= 0"
1 <= 0

skriv "Testar 1 >= 0"
1 >= 0

skriv "Testar 0 >= 1"
0 >= 1

skriv "Testar 1 != 0"
1 != 0

skriv "Testar 1 != 1"
1 != 1
#2 * 5
#100.0 / 3.0
skriv "hej igen"'}
=end
#puts sn.run(true) {"(1 + 4)*5
#"}
#puts sn.run(true) {"a
#"}
#puts sn.run(true) {'skriv "hej på dig"
#'}
#=end

