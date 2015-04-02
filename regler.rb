# -*- coding: utf-8 -*-
require './rdparse'
require './klasser'


class StartaNu
  
  def initialize(filnamn = nil)
    @fil = filnamn
    @@variables = {}
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
      token(/startaNu/) { |m| m }
      token(/slutaNu/) { |m| m }
      token(/[\w]+/) { |m| m } # Matcha ord
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
        match(:loop)
        match(:om)
        match(:deklarering)
        match(:tilldelning)
        match(:jamforelse) { |jamforelse| [jamforelse]} # Endast här för testning
        match(:aritm_uttryck) {|aritm_uttryck| [aritm_uttryck]} # Endast här för testning
        match(:funktion)
        match(:skriv) {|skriv| [skriv]}
        #match(:get_variabel)
        match(:nyrad) {|nyrad| [nyrad]}
      end

      rule :uttryck do
        #match(:jamförelse) # Kanske ska vara här, borttaget pga stack level to deep
        #match(:logiskt_uttryck) # Kanske ska vara här, borttaget pga stack level to deep
        match(:aritm_uttryck)
        match(:identifierare)
        match(:f_anrop)
      end

      rule :loop do
        match("för", :identifierare, :heltal, :nyrad, "start", :nyrad, :satser, "slut")
        match("medans", :jamforelse, :nyrad, "start", :nyrad, :satser, "slut")
      end

      rule :om do
        match("om", :logiskt_uttryck, :nyrad, "start", :nyrad, :satser, "slut")
        match("om", :logiskt_uttryck, :nyrad, "start", :nyrad, :satser, :annars_kropp, "slut")
      end

      rule :annars_kropp do
        match("annars", :nyrad, :satser)
      end

      ###################### Variabeldeklarering / tilldelning #######
      rule :deklarering do
        #match("skapa",:tilldelning) { |_, tilldelning| tilldelning }
        match("skapa",:identifierare,"=",:uttryck) #{ |_,name, _, value| @@variables[name] = value}
        match("skapa",:identifierare) #{ |_, name| @@variables[name] = 0 }
        #match("skapa",:variabel,"=",/\w+/) { |_,name, _, value| @@variables[name] = value[1..-2]}
      end

      rule :tilldelning do
        match(:identifierare,"=",:uttryck) #{ |name, _, value| @@variables[name] = value}
        #match(:get_variabel,"=",/\w+/) { |name, _, value| @@variables[name] = value[1..-2] }
      end

      rule :funktion do
        match("skapa metoden", :identifierare, :parameter_lista, :nyrad, "start", :nyrad, :satser, "slut")
        match("skapa metoden", :identifierare, :nyrad, :satser, "slut")
      end
      
      rule :parameter_lista do
        match(:identifierare, ",", :parameter_lista)
        match(:identifierare)
      end

      rule :identifierare do
        match(:name)
      end

      # Här är det nog lite fel..........
      rule :logiskt_uttryck do
        match(:logiskt_uttryck, :logisk_operator, :logiskt_uttryck)
        match(:jamforelse)
      end

      rule :logisk_operator do
        match("och")
        match("eller")
        match("inte är")
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
        #match('skriv', :get_variabel) { |_, att_skriva_ut| att_skriva_ut }
      end
      ###################### Slut skriv / print ########

      rule :name do
        match(/[\wåäöÅÄÖ]+/)
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

sn.run(true) {'skriv "hej world"
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
#2 * 5
#100.0 / 3.0
skriv "hej igen"'}
#puts sn.run(true) {"(1 + 4)*5
#"}
#puts sn.run(true) {"a
#"}
#puts sn.run(true) {'skriv "hej på dig"
#'}
#=end

