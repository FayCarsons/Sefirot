#include "sys/socket.h"
#include "netinet/in.h"
#include <math.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <errno.h>
#include <stdio.h>
#include <stdbool.h>

#define DEBUG false

// String must be borrowed!
const char *kk_string_to_buf(kk_string_t s, kk_context_t *ctx)
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

kk_std_core_exn__error kk_socket(int domain, int socktype, kk_context_t *ctx)
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

intptr_t new_sockaddr(int family, int addr_type, int port)
{
  struct sockaddr_in *addr = malloc(sizeof(struct sockaddr_in));

  addr->sin_family = family;
  addr->sin_addr.s_addr = htonl(addr_type);
  addr->sin_port = htons(port);
  return (intptr_t)addr;
}

// Connect and bind must be wrapped so that we can handle casting an intptr_t
// to a sockaddr

int do_bind(int sock, intptr_t addr_)
{
  struct sockaddr *addr = (struct sockaddr *)addr_;
  return bind(sock, addr, sizeof(struct sockaddr));
}

int do_connect(int sock, intptr_t addr_)
{
  struct sockaddr *addr = (struct sockaddr *)addr_;
  return connect(sock, addr, sizeof(*addr));
}

kk_std_core_exn__error kk_accept(int sock, kk_context_t *ctx)
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
kk_std_core_exn__error kk_send(int sock, kk_string_t str, kk_context_t *ctx)
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
kk_string_t kk_recv(int sock, kk_context_t *ctx)
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