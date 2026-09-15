#include <stdio.h>

/* deliberately returns the address of an automatic object */

static int *scope(void) {
  int x = 42;
  return &x; /* x's lifetime ends at block exit */
}

int main(void) {
  int *p = scope();
  /* p dangles: the standard says its value is indeterminate */
  printf("dangling: %d\n", *p);
  return 0;
}