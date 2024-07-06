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

extern unsafe-host-addr(domain : int32, addr-type : int32, port : int32): intptr_t
  c "host_addr"

extern unsafe-client-addr(domain : int32, ^ip : string, port : int32): intptr_t
  c "kk_client_addr"

extern unsafe-bind(fd : int32, addr : intptr_t): int32
  c "do_bind"

extern unsafe-listen(fd : int32, backlog : int32): int32
  c "listen"

extern unsafe-accept(fd : int32): error<int32>
  c "kk_accept"

extern unsafe-close(fd : int32): int32 
  c "close"

extern unsafe-string-send(fd : int32, ^msg : string): error<int32>
  c "kk_string_send"

extern unsafe-string-recv(fd : int32): exn string 
  c "kk_string_recv"

extern unsafe-connect(fd : int32, addr : intptr_t): int32 
  c "do_connect"

// Create a Socket, returning its file descriptor 
pub fun socket(domain : domain, socktype  : socket-type): exn socket   {
  unsafe-socket(int32(domain), int32(socktype))
    .untry
    .Socket
}

// TODO: add error handling
// Allocate a Sockaddr for a host socket and return a pointer to it
pub fun host(domain : domain, addr: address, port : int): exn sockaddr 
  val ptr : intptr_t = unsafe-host-addr(
    int32(domain),
    int32(addr),
    int32(port))
  if int(ptr) < 0 
    then throw-exn(Exception("Error instantiating host sockaddr", SocketError))
    else Sockaddr(ptr)

pub fun client(domain : domain, ip : string, port : int): exn sockaddr 
  val ptr = unsafe-client-addr(int32(domain), ip, int32(port))
  if (int(ptr) < 0) 
    then throw-exn(Exception("Error instantiating client sockaddr", SocketError))
    else Sockaddr(ptr)

// Accept a connection, returning a new Socket(File Descriptor)
pub fun accept(Socket(fd) : socket): exn socket
  unsafe-accept(fd)
    // `untry` so user can decide how they want to handle exns
    .untry
    .Socket

// Bind socket to address/configuration described by Sockaddr
pub fun bind(Socket(fd) : socket, Sockaddr(addr) : sockaddr): exn ()
  if unsafe-bind(fd, addr) < int32(0) 
    then throw-exn(Exception("Cannot bind socket to address", SocketError))

// Set socket to listen
pub fun listen(Socket(fd) : socket, backlog : int): exn ()
  if unsafe-listen(fd, int32(backlog)) < int32(0)
    then throw-exn(Exception("Listening on socket failed", SocketError))

// TODO: add mutable byte type and send/receive
// Send a string
pub fun string/send(Socket(fd) : socket, ^msg : string): exn int
  match unsafe-string-send(fd, msg) 
    Ok(written) -> int(written)
    Error(Exception(message, info)) -> throw-exn(Exception("Send failed: " ++ message, info)) 

// Receive a string
pub fun string/recv(Socket(fd)) : exn string
  unsafe-string-recv(fd)

// Close a socket
pub fun close(Socket(fd)): exn ()
  if unsafe-close(fd) < int32(0) 
    then throw-exn(Exception("Cannot close socket!", SocketError))

// TODO:
// fun connect
// fun peername
// fun shutdown
