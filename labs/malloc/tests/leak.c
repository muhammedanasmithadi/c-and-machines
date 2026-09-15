#include <stdio.h>
#include <stdlib.h>

/* deliberately leaks: 40 bytes reachable then dropped */

int main(void) {
  char *p = malloc(40);
  if (!p) return 1;
  sprintf(p, "phantom");
  /* never free(p): the room stays in the ledger */
  printf("leak: %s\n", p);
  return 0;
}