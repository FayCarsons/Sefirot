import socket 

fun handle-client(client : socket)
  val msg = client.recv
  println("RECEIVED: " ++ msg)
  if msg.count == 0 
    then
      ()
    else
      client.send(msg).ignore
      handle-client(client)

fun server(sock : socket)
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

