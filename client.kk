import socket 

// Very simple outline
// TODO: 'server' effect that handles stopping/continuing a server

value struct client
  sock : socket

value struct builder
  domain : domain = Ipv4
  mode : mode = TCP
  sockaddr : maybe<sockaddr> = Nothing

pub fun with-domain(Builder(_, mode, sockaddr), domain : domain): builder
  Builder(domain, mode, sockaddr)

pub fun with-mode(Builder(domain, _, sockaddr), mode : mode): builder
  Builder(domain, mode, sockaddr)

pub fun with-address(Builder(domain, mode, _), ip : string, port : int)
  val sockaddr-ptr = client(domain,ip, port)
  Builder(domain, mode, Just(sockaddr-ptr))

pub fun build(Builder(domain, mode, sockaddr) : client/builder): exn client
  match  sockaddr 
    Just(addr) -> 
      val sock = socket(domain, mode.to-stype)
      sock.connect(addr)
      Client(sock)
    Nothing -> 
      throw-exn(Exception(
        "Attempt to build Client with null address, use client.with-address(ip, port) to set address before building", 
        SocketError))

pub fun client/send(Client(sock), msg : string): exn int
  sock.send(msg)

pub fun client/request(Client(sock), req : string): exn string
  sock.send(req)
  sock.recv()

pub fun client/close(Client(sock))
  sock.socket/close

pub fun client/oneshot(client, req : string): <exn|e> string
  with finally { client.client/close }
  client.request(req)
