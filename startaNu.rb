# -*- coding: utf-8 -*-
require './regler'

fil = ARGV[0]

if fil != nil
  startanu = StartaNu.new(fil)
  startanu.start
else
  sn = StartaNu.new
  sn.run
end
