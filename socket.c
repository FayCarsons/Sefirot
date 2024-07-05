#include "sys/socket.h"
#include "netinet/in.h"
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <stdbool.h>

kk_string_t kk_test_string(kk_context_t *ctx) {
  const char* s = "Hewwo :3";
  return kk_string_alloc_from_utf8(s, ctx);
}

kk_std_core_exn__error kk_socket(int domain, int socktype, kk_context_t *ctx) { 
  int sockfd = socket(domain, socktype, 0); 

  if (sockfd < 0 ) {
    return kk_error_from_errno(errno, ctx);
  } else {
    return kk_error_ok(kk_int32_box(sockfd, ctx), ctx);
  }
}

intptr_t new_sockaddr(int family, int addr_type, int port) {
  struct sockaddr_in *addr = malloc(sizeof(struct sockaddr_in));
  
  addr->sin_family = family;
  addr->sin_addr.s_addr = htonl(addr_type);
  addr->sin_port = htons(port);
  return (intptr_t)addr;
}

int do_bind(int sock, struct sockaddr *sockaddr) {
  int res = bind(sock, sockaddr, sizeof(struct sockaddr_in));
  if (res < 0) {
    close(sock);
    printf("Cannot bind socket to sockaddr!\n");
    exit(1);
  }
}

kk_std_core_exn__error kk_accept(int sock, kk_context_t *ctx) {
  struct sockaddr_in client_addr;
  socklen_t client_len = sizeof(client_addr);
  int *client_fd = malloc(sizeof(int));
  int try_client = accept(sock, (struct sockaddr *)&client_addr, &client_len);
  if (try_client < 0) {
    return kk_error_from_errno(errno, ctx); 
  } else { 
    client_fd = try_client;
    return kk_error_ok(kk_int32_box(client_fd, ctx), ctx); 
  }
}

int do_connect(int sock, struct sockaddr *server_addr) {
  int res = connect(sock, server_addr, sizeof(*server_addr));
  if (res < 0) {
    printf("Cannot connect!\n");
    exit(1);
  }
  return res;
}

int do_listen(int sock, int backlog) { 
  int res = listen(sock, backlog); 
  if (res < 0) {
    printf("Cannot listen\n");
    exit(1);
  } else {
    return res;
  }
}

kk_std_core_exn__error kk_send(int sock, kk_string_t str, kk_context_t *ctx) {
  kk_ssize_t len = kk_string_len_borrow(str, ctx);
  char *bytes = kk_string_cbuf_borrow(str, len, ctx);
  ssize_t sent = send(sock, (void*)bytes, len, 0);

  if (sent < 0) {
    printf("Error sending message!\n errno = %d", errno);
    return kk_error_from_errno(errno, ctx);
  } else {
    return kk_error_ok(kk_int32_box(sent, ctx), ctx);
  }
}

#define BUFFER_SIZE 1024 // Static buffer size for testing
kk_string_t kk_recv(int sock, kk_context_t* ctx) {
  char buffer[BUFFER_SIZE];
  ssize_t received = recv(sock, (void*)buffer, BUFFER_SIZE, 0);
  printf("STRING STUFF");
  printf("NUM BYTES RECEIVED: %d\n", received);
  printf("BUFFER IS NULL? %s\n", buffer == NULL ? "True" : "False");
  printf("BUFFER[0] == 0?: %s\n", buffer[0] == 0 ? "True" : "False");

  if (received < 0) {
    kk_error_from_errno(errno, ctx);
  }

  return kk_string_alloc_from_utf8n(received, buffer, ctx);
}

void do_close(int fd) {
   int res = close(fd); 
}