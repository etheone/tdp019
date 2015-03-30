# -*- coding: utf-8 -*-
require './regler'

fil = ARGV[0]

if fil != nil
  startanu = StartaNu.new(fil)
  startanu.start
else
  puts "Måste ange ett filnamn att köra!"
end
