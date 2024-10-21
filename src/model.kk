import std/num/int32 

extend type exception-info
  SocketError

type domain
  Local
  Ipv4
  Ipv6

fun domain/int32(d : domain)
  match d 
    Ipv4 -> int32(2) 
    Ipv6 -> int32(10) 
    Local -> int32(1) 

type socket-type 
  Stream
  Datagram
  Raw
  SeqPacket

// Higher level abstraction over protocols used by client and host APIs
// TODO: solve naming conflicts, add raw and seqpacket
type protocol 
  TCP 
  UDP

fun to-stype(protocol : protocol)
  match protocol 
    TCP -> Stream 
    UDP -> Datagram

fun socket-type/int32(t : socket-type)  
  match t 
    Stream -> int32(1) 
    Datagram -> int32(2)
    Raw -> int32(3)
    SeqPacket -> int32(5)

type address 
  Any
  Loopback

fun address/int32(a : address) 
  match a 
    Any -> int32(0x00000000)
    Loopback -> int32(0x7F000001)

type shutdown
  Read 
  Write 
  All

pub fun shutdown/int32(s : shutdown)
  match s 
    Read -> int32(0)
    Write -> int32(1)
    All -> int32(2)

value struct socket 
  inner : int32

value struct sockaddr
  inner : intptr_t
