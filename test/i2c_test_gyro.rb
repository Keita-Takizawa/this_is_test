
 require "./I2C.rb"

 bus_address = 1
 sle_address = 0x6a
 power_enable = 0x20
 setval = 0x0f
 x_address = 0x29
 # bunnkainou = 0.00875
 ave = 2

 def mult(xyz)
   out = []
   xyz.each do |x|
     out.push(x * 0.00875)
   end
   return out
 end

 l3gd20 = I2C.new(bus_address, sle_address)
 l3gd20.i2c_set(power_enable, setval)

 time = Time.now
 30.times do
   puts ([Time.new - time] + mult(l3gd20.averageB(x_address, ave))).join(',')
 end
