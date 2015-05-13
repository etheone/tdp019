# read command from standard input:
require './regler'

# remove whitespaces:

#while true
input = STDIN.gets("STOPNU")

#  input = 'STOP'
#  if input == 'STOP'
#    break
#  end
#end


code = input.chomp! "STOPNU"

# if command is "exit", terminate:

# else evaluate command, send result to standard output:
sn = StartaNu.new

sn.run(true){code}
print '[end]'

# flush stdout to avoid buffering issues:
#STDOUT.flush


