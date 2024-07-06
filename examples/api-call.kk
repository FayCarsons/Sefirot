import socket


val req = 
  "GET /status/200 HTTP/1.1\r\nHost: httpbin.org\r\nConnection: close\r\n\r\n"

pub fun main()
  val sock = socket(AF-Inet, Stream)
  val host-addr = client(AF-Inet, "3.227.135.8", 80)
  println("Connecting to host . . . ")
  sock.connect(host-addr)
  println("Sending request . . .")
  sock.send(req)
  val res = sock.recv()
  println("RESPONSE: \n\n" ++ res)