
// Example using the host and client APIs
import sefirot

// Host - run an echo server that stops when it receives the message "quit"

fun init() 
  host/Builder().with-port(8080).build

fun loop(host : host)
  host.run (
    fn (client)
      val msg = client.recv
      if msg.trim == "quit" 
      then stop()
      else client.socket/send(msg.to-upper).ignore
  )

// Client - make a single request

val req = 
  "GET /status/200 HTTP/1.1\r\nHost: httpbin.org\r\nConnection: close\r\n\r\n"

fun client-request()
  client/Builder().with-address("3.227.135.8", 80).build.oneshot(req)

pub fun main()
  client-request()
  init().loop