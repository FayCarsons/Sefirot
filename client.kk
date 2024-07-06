import socket 

value struct client
  sock : socket
  addr : sockaddr

value struct builder
    domain : domain
    sock : socket
    addr : sockaddr
