# -*- coding: binary -*-

module Msf

###
#
# Network address range option.
#
###
class OptAddressRange < OptBase
  def type
    return 'addressrange'
  end

  def normalize(value)
    return nil unless value.kind_of?(String)
    if value =~ /^rand:(.*)/
      count = $1.to_i
      return false if count < 1
      ret = ''
      count.times do
        ret << ' ' if not ret.empty?
        ret << [ rand(0x100000000) ].pack('N').unpack('C*').map{|x| x.to_s }.join('.')
      end
      return ret
    end

    value
  end

  def valid?(value)
    return false if empty_required_value?(value)
    return false unless value.kind_of?(String) or value.kind_of?(NilClass)

    if (value != nil and value.empty? == false)
      normalized = normalize(value)
      return false if normalized.nil?
      walker = Rex::Socket::RangeWalker.new(normalized)
      if (not walker or not walker.valid?)
        return false
      end
    end

    return super
  end
end

end
