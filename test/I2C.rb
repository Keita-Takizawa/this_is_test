#coding: utf-8
#!/usr/bin/ruby

class I2C
  def initialize(badr,sler)
    @bus_adr = badr
    @sle_adr = sler
  end

  def hex2dec(hex)
    sum = 0
    (hex.length).times do |n|
      a = 0
      if (hex[n] >= 'a') and (hex[n] <= 'f')
        a = (hex[n].encode("UTF-8").ord - 'a'.encode("UTF-8").ord + 10)
      elsif (hex[n] >= '0') and (hex[n] <= '9')
        a = hex[n].to_i
      else
        abort "(#{hex} -> hex2dec) => Out range ... erorr ."
      end
      sum = sum + (a * (16 ** (hex.length - n - 1)))
    end
    return sum
  end

  def dec2hex(dec)
    div = dec / (16)
    if div >= 1
      return (dec2hex div) + (d2h dec)
    else
      return (d2h dec)
    end
  end

  def signed_int(word_dec)
    if (word_dec >= 0x8000) and (word_dec <= 0xffff)
      return -((65535 - word_dec) + 1)
    elsif (word_dec >= 0) and (word_dec < 0x8000)
      return word_dec
    else
      abort "(#{word_dec} -> signed_int) => Out range ... erorr ."
    end
  end

  # i2c
  def i2c_set(adress,set_val)
  `sudo i2cset -y #{@bus_adr} #{@sle_adr} #{adress} #{set_val} i`
  end
  
  def i2c_get(adress)
    byte = `sudo i2cget -y #{@bus_adr} #{ @sle_adr} #{adress}`
    return byte[2]+byte[3]
  end

  def i2c_get_wordB(adress)
    word = `sudo i2cget -y #{@bus_adr} #{ @sle_adr} #{adress} w`
    return word[2]+word[3]+word[4]+word[5]
  end

  def i2c_get_wordL(adress)
    word = `sudo i2cget -y #{@bus_adr} #{ @sle_adr} #{adress} w`
    return word[4]+word[5]+word[2]+word[3]
  end

  def get_xyzB(xadr)
    x = i2c_get_wordB(xadr)
    y = i2c_get_wordB(xadr+2)
    z = i2c_get_wordB(xadr+4)
    return (xyz_trans [x,y,z])
  end

  def get_xyzL(xadr)
    x = i2c_get_wordL(xadr)
    y = i2c_get_wordL(xadr+2)
    z = i2c_get_wordL(xadr+4)
    return (xyz_trans [x,y,z])
  end

  def averageB(xadr,ave)
    xyz = [0,0,0]
    newxyz = []
    ave.times do
      xyz = ap(xyz ,get_xyzB(xadr))
    end
    xyz.each do |x|
      newxyz.push(x / ave)
    end
    return newxyz
  end

  private

  def d2h(dec)
    mod = dec % (16)
    if (mod == 10)
      return "a"
    elsif (mod == 11)
      return "b"
    elsif (mod == 12)
      return "c"
    elsif (mod == 13)
      return "d"
    elsif (mod == 14)
      return "e"
    elsif (mod == 15)
      return "f"
    else
      return mod.to_s
    end
  end

  def xyz_trans(xyz_arr)
    out = []
    xyz_arr.each do |x|
      out.push(signed_int(hex2dec(x)))
    end
    return out
  end

  def ap(xyz0,xyz1)
    return([xyz0[0]+xyz1[0],xyz0[1]+xyz1[1],xyz0[2]+xyz1[2]])
  end
end
