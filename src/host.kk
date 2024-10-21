import src/bindings
import src/model
// Higher level API

val default-backlog = 10

value struct builder
  domain : domain = Ipv4
  backlog : int = 10
  protocol : protocol = TCP
  addr : maybe<sockaddr> = Nothing

value struct host 
  socket : socket
  addr : sockaddr

pub fun with-domain(Builder(_, backlog, mode, addr) : builder, domain : domain)
  Builder(domain, backlog, mode, addr)

pub fun with-backlog(Builder(domain, _, mode, addr) : builder, backlog : int)
  Builder(domain, backlog, mode, addr)

pub fun with-mode(Builder(domain, backlog, _,
addr) : builder, protocol : protocol)
  Builder(domain, backlog, protocol, addr)

pub fun with-addr(Builder(domain, backlog, mode, _), addr : sockaddr): builder 
  Builder(domain, backlog, mode, Just(addr))

// TODO: make this, and all builder fns, FIP
pub fun with-port(builder : builder, port : int, addr-config = Loopback): exn builder
  val addr = bindings/host(builder.domain, addr-config, port)
  builder.with-addr(addr)

pub fun build(Builder(domain, backlog, mode, addr)): exn host
  match addr 
    Just(addr) ->
      val stype = mode.to-stype
      val sock = socket(domain, stype)
      sock.bind(addr)
      sock.listen(backlog)
      Host(sock, addr)
    Nothing -> throw-exn(Exception(
      "Attempt to build Host with null port, use host/with-port(port_num) before building", 
      SocketError))

effect server 
  ctl stop(): ()

pub fun host/run(Host(sock, _), action : socket -> <exn, server> ())
  with finally { sock.close }
  with handler 
    ctl stop() 
      println("Host closed!")
      return(())
  while { True }
    val client = sock.accept
    action(client)
    client.close() 
