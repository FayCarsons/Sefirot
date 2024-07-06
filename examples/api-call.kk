import socket

// Simple get request that should always return 200
val req = 
  "GET /status/200 HTTP/1.1\r\nHost: httpbin.org\r\nConnection: close\r\n\r\n"

fun valid-response(res : string)
  val Cons(status, _) = res.lines
  status.trim == "HTTP/1.1 200 OK"

pub fun main()
  val sock = socket(Ipv4, Stream)
  // Close socket at end of fn, regardless of exceptions
  with finally  
    sock.close
  
  // Httpbin.org, HTTP
  val host-addr = client(Ipv4, "3.227.135.8", 80)
  println("Connecting to host . . . ")
  sock.connect(host-addr)
  println("Sending request . . .")
  sock.send(req)

  val res = sock.recv()
  println("\nRESPONSE:\n" ++ res)
  if !valid-response(res)
    then throw-exn(Exception("Incorrect response", SocketError))
    else println("OK")