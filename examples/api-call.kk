import socket

// Simple get request that should always return 200
val req = 
  "GET /status/200 HTTP/1.1\r\nHost: httpbin.org\r\nConnection: close\r\n\r\n"

fun valid-response(res : string)
  val Cons(status, _) = res.lines
  status.trim == "HTTP/1.1 200 OK"

pub fun main()
  val sock = socket(AF-Inet, Stream)
  // Httpbin.org, plain HTTP
  val host-addr = client(AF-Inet, "3.227.135.8", 80)
  println("Connecting to host . . . ")
  sock.connect(host-addr)
  println("Sending request . . .")
  sock.send(req)
  val res = sock.recv()
  println("\nRESPONSE:\n" ++ res)
  if valid-response(res)
    then ()
    else throw-exn(Exception("Incorrect response", SocketError))