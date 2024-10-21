import sefirot 

// Read a message from the client connection, print it, and echo it uppercased
fun handle-client(client : socket): <pure, console> ()
  val msg = client.recv
  val len = msg.count
  if len == 0 || msg.trim == "quit"
    then
      ()
    else
      println("Got: " ++ msg)
      if client.send(msg.to-upper) != len 
        then throw-exn(Exception("partial write", SocketError))
      // Recurse if successful
      handle-client(client)

// Handle clients sequentially
fun server(sock : socket): <pure, console> ()
  // loop forever, unless an exception is thrown
  while 
    // Catch exceptions, printing them and breaking the loop
    with handler 
      return(_unit) True
      final ctl throw-exn(exn)
        println("Error handling client: " ++ exn.message) 
        False 
    // All three of these expressions can throw, hence handling the effect as 
    // opposed to using ADTs and pattern matching
    val client = sock.accept()
    handle-client(client)
    client.close
  {}


pub fun main(): <pure, console> ()
  // Initialize a TCP socket
  val sock = socket(Ipv4, Stream)
  // Close socket at end of main
  with finally { sock.close }
  // Create a Sockaddr object
  val sockaddr = host(Ipv4, Any,  3000 )
  // Bind the socket to the addr
  sock.bind(sockaddr)
  // Set to listen, with a max of 10 connections
  sock.listen(10)
  // Start server
  println("Starting server!")
  server(sock) 
  

