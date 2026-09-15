#include <stdio.h>
#include <stdlib.h>

/* deliberately double-frees one block */

int main(void) {
  int *p = malloc(sizeof(int));
  if (!p) return 1;
  *p = 42;
  printf("double-free: %d\n", *p); /* read while owned, safe */
  free(p);
  free(p); /* returning the same block twice */
  return 0;
}