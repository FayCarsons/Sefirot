import std/num/int32 

extend type exception-info
  SocketError

type domain
  AF-Unix
  AF-Inet
  AF-Inet6

fun domain/int32(d : domain)
  match d 
    AF-Inet -> int32(2) 
    AF-Inet6 -> int32(10) 
    AF-Unix -> int32(1) 

type socket-type 
  Stream
  Datagram
  Raw
  SeqPacket

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

value struct socket 
  inner : int32

value struct sockaddr
  inner : intptr_t

extern import 
  c file "socket.c"

extern unsafe-socket(domain : int32, socktype : int32): error<int32> 
  c "kk_socket"

extern unsafe-sockaddr(domain : int32, addr-type : int32, port : int32): intptr_t
  c "new_sockaddr"

extern unsafe-bind(fd : int32, addr : intptr_t): int32
  c "do_bind"

extern unsafe-listen(fd : int32, backlog : int32): int32
  c "listen"

extern unsafe-accept(fd : int32): error<int32>
  c "kk_accept"

extern unsafe-close(fd : int32): int32 
  c "close"

extern unsafe-send(fd : int32, ^msg : string): error<int32>
  c "kk_send"

extern unsafe-recv(fd : int32): exn string 
  c "kk_recv"
  
pub fun socket(domain : domain, socktype  : socket-type)   {
  unsafe-socket(int32(domain), int32(socktype)).untry.Socket
}

pub fun sockaddr(domain : domain, addr: address, port : int) 
  val ptr = unsafe-sockaddr(
    int32(domain),
    int32(addr),
    int32(port))
  Sockaddr(ptr)

pub fun accept(Socket(fd) : socket)
  unsafe-accept(fd).untry.Socket

pub fun bind(Socket(fd) : socket, Sockaddr(addr) : sockaddr)
  if unsafe-bind(fd, addr) < 0.int32 
    then throw-exn(Exception("Cannot bind socket to address", SocketError))

pub fun listen(Socket(fd) : socket, backlog : int)
  if unsafe-listen(fd, int32(backlog)) < int32(0)
    then throw-exn(Exception("Listening on socket failed", SocketError))

pub fun send(Socket(fd) : socket, ^msg : string): exn int32
  match unsafe-send(fd, msg) 
    Ok(written) -> written 
    Error(Exception(message, info)) -> throw-exn(Exception("Send failed: " ++ message, info)) 

pub fun recv(Socket(fd)) : exn string
  unsafe-recv(fd)

pub fun close(Socket(fd)) 
  if unsafe-close(fd) < int32(0) 
    then throw-exn(Exception("Cannot close socket!", SocketError))

// TODO:
// fun connect
// fun peername
// fun shutdown
