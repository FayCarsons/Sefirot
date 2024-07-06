#include "sys/socket.h"
#include "netinet/in.h"
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <stdbool.h>
#include <arpa/inet.h>

#define DEBUG false

// String must be borrowed!
const char *kk_string_to_buf(const kk_string_t s, kk_context_t *ctx)
{
  const kk_bytes_t bytes = s.bytes;
  kk_ssize_t len = kk_bytes_len_borrow(bytes, ctx);
  return kk_bytes_cbuf_borrow(bytes, &len, ctx);

#if DEBUG
  /* ---- DEBUGGING ---- */
  printf("STRING->BUF INVARIANTS: \n");
  printf("BYTES IS NULL?: %s\n", buf == NULL ? "True" : "False");
  printf("BUFFER[0] == 0?: %s\n", buf[0] == 0 ? "True" : "False");
#endif
}

kk_std_core_exn__error kk_socket(const int domain, const int socktype, kk_context_t *ctx)
{
  int sockfd = socket(domain, socktype, 0);

  if (sockfd < 0)
  {
    return kk_error_from_errno(errno, ctx);
  }
  else
  {
    return kk_error_ok(kk_int32_box(sockfd, ctx), ctx);
  }
}

intptr_t host_addr(const int domain, const int addr_type, const int port)
{
  struct sockaddr_in *addr = malloc(sizeof(struct sockaddr_in));
  if (addr == NULL) return (intptr_t)-1;

  addr->sin_family = domain;
  addr->sin_addr.s_addr = htonl(addr_type);
  addr->sin_port = htons(port);
  return (intptr_t)addr;
}

intptr_t kk_client_addr(const int domain, const kk_string_t ip, const int port, kk_context_t *ctx)
{
  struct sockaddr_in *host_addr = malloc(sizeof(struct sockaddr_in));
  host_addr->sin_family = domain;
  host_addr->sin_port = htons(port);

  const char *ip_s = kk_string_to_buf(ip, ctx);
  int try = inet_pton(domain, ip_s, &host_addr->sin_addr);
  return (intptr_t)(try < 0 ? try : host_addr);
}

// Connect and bind must be wrapped so that we can handle casting an intptr_t
// to a sockaddr

int do_bind(const int sock, const intptr_t addr_)
{
  struct sockaddr *addr = (struct sockaddr *)addr_;
  return bind(sock, addr, sizeof(struct sockaddr));
}

int do_connect(const int sock, const intptr_t addr_)
{
  struct sockaddr *addr = (struct sockaddr *)addr_;
  return connect(sock, addr, sizeof(*addr));
}

kk_std_core_exn__error kk_accept(const int sock, kk_context_t *ctx)
{
  struct sockaddr_in client_addr;
  socklen_t client_len = sizeof(client_addr);
  int try_client = accept(sock, (struct sockaddr *)&client_addr, &client_len);
  if (try_client < 0)
  {
    return kk_error_from_errno(errno, ctx);
  }
  else
  {
    return kk_error_ok(kk_int32_box(try_client, ctx), ctx);
  }
}

// String must be borrowed?
kk_std_core_exn__error kk_string_send(const int sock, const kk_string_t str, kk_context_t *ctx)
{
  const kk_bytes_t bytes = str.bytes;
  kk_ssize_t len = kk_bytes_len_borrow(bytes, ctx);
  const char *buf = kk_bytes_cbuf_borrow(bytes, &len, ctx);

  int sent = (int)send(sock, (void *)buf, len, 0);

#if DEBUG
  printf("BYTES SENT: %d\n", sent);
#endif

  if (sent < 0)
  {
    printf("Error sending message!\n errno = %d", errno);
    return kk_error_from_errno(errno, ctx);
  }
  else
  {
    return kk_error_ok(kk_int32_box(sent, ctx), ctx);
  }
}

#define BUFFER_SIZE 1024 // Static buffer size for testing
kk_string_t kk_string_recv(const int sock, kk_context_t *ctx)
{
  char buffer[BUFFER_SIZE];
  ssize_t received = recv(sock, (void *)buffer, BUFFER_SIZE, 0);

#if DEBUG
  printf("KK_RECEIVE INVARIANTS: \n");
  printf("NUM BYTES RECEIVED: %d\n", received);
  printf("BUFFER IS NULL? %s\n", buffer == NULL ? "True" : "False");
  printf("BUFFER[0] == 0?: %s\n", buffer[0] == 0 ? "True" : "False");
#endif

  if (received < 0)
  {
    kk_error_from_errno(errno, ctx);
  }

  return kk_string_alloc_from_utf8n(received, buffer, ctx);
}

kk_std_core_exn__error kk_shutdown(int fd, int how, kk_context_t *ctx) 
{
  if (shutdown(fd, how) == -1)
    return kk_error_from_errno(errno, ctx);
  else 
    return kk_error_ok(kk_unit_box(kk_Unit), ctx);
}