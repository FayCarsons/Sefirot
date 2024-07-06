import socket
// Higher level API

val default-backlog = 10

type mode 
  TCP 
  UDP
  Raw

value struct builder
  domain : domain
  backlog : int
  socket : socket
  addr : maybe<sockaddr>

value struct host 
  socket : socket
  addr : sockaddr

pub fun host/new(mode : mode = TCP, domain = Ipv4): exn builder
  val stype = match mode 
    TCP -> Stream 
    UDP -> Datagram
  val sock = socket(domain, stype)
  Builder(domain, default-backlog, sock, Nothing)

pub fip fun with-addr(Builder(domain, backlog, sock, _), addr : sockaddr): builder 
  Builder(domain, backlog, sock, Just(addr))

// TODO: make this, and all builder fns, FIP
pub fun host/with-port(builder : builder, port : int, addr-config = Loopback): exn builder
  val addr = socket/host(builder.domain, addr-config, port)
  builder.with-addr(addr)

pub fun host/build(Builder(_, backlog, sock, addr)): exn host
  match addr 
    Just(addr) ->
      sock.bind(addr)
      sock.listen(backlog)
      Host(sock, addr)
    Nothing -> throw-exn(Exception("Cannot build host w/o setting port", SocketError))

// Take a fn that accepts a client connection, and run it 
// TODO: Stopping conditions, maybe cleanup
pub fun host/run(Host(sock, _), action : socket -> <div,exn|e> ()): <div,exn|e> ()
  while { True }
    val client = sock.accept
    action(client)
    client.close()
    
