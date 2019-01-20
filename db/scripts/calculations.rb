require 'rubygems'

elo1 = 0
elo2 = 0
elo3 = 0
Player.all.each do |p|
  elo1 = elo1 + p.elo
  elo2 = elo2 + p.elov2
  elo3 = elo3 + p.elov3
end
  puts "ELO #{(elo1 / 15)}"
  puts "ELOv2 #{(elo2 / 15)}"
  puts "ELOv3 #{(elo3 / 15)}"