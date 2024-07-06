import socket
// Higher level API
// TODO: investigate linear effects for builder pattern

val default-backlog = 10

value struct builder
  domain : domain = Ipv4
  backlog : int = 10
  mode : mode = TCP
  addr : maybe<sockaddr> = Nothing

value struct host 
  socket : socket
  addr : sockaddr

pub fun with-domain(Builder(_, backlog, mode, addr) : builder, domain : domain)
  Builder(domain, backlog, mode, addr)

pub fun with-backlog(Builder(domain, _, mode, addr) : builder, backlog : int)
  Builder(domain, backlog, mode, addr)

pub fun with-mode(Builder(domain, backlog, _, addr) : builder, mode : mode)
  Builder(domain, backlog, mode, addr)

pub fun with-addr(Builder(domain, backlog, mode, _), addr : sockaddr): builder 
  Builder(domain, backlog, mode, Just(addr))

// TODO: make this, and all builder fns, FIP
pub fun host/with-port(builder : builder, port : int, addr-config = Loopback): exn builder
  val addr = socket/host(builder.domain, addr-config, port)
  builder.with-addr(addr)

pub fun host/build(Builder(domain, backlog, mode, addr)): exn host
  match addr 
    Just(addr) ->
      val stype = mode.to-stype
      val sock = socket(domain, stype)
      sock.bind(addr)
      sock.listen(backlog)
      Host(sock, addr)
    Nothing -> throw-exn(Exception("Attempt to build Host with null port, use host/with-port(port_num) before building", SocketError))

// Take a fn that accepts a client connection, and run it 
// TODO: Stopping conditions, maybe cleanup
pub fun host/run(Host(sock, _), action : socket -> <div,exn|e> ()): <div,exn|e> ()
  while { True }
    val client = sock.accept
    action(client)
    client.close()
    
