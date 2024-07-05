import socket 

fun handle-client(client : socket): <pure, console> ()
  val msg : string = client.recv
  if msg.count == 0 || msg.trim == "quit"
    then
      ()
    else
      client.send(msg.to-upper).ignore
      handle-client(client)

fun server(sock : socket): <pure, console> ()
  while { True }
    val client = sock.accept()
    handle-client(client) 
    client.close()
    server(sock)


pub fun main() 
  println("Starting server :3")
  // Initialize a TCP socket
  val sock = socket(AF-Inet, Stream) 
  // Configure its address
  val sockaddr = sockaddr(AF-Inet, Any,  3000 )
  // Bind it to the address
  sock.bind(sockaddr)
  sock.listen(10)
  server(sock) 
  sock.close

