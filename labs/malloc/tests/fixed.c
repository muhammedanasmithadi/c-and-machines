#include <stdio.h>
#include <stdlib.h>

/* the sound design: allocated storage outlives the call, freed exactly once */

static int *room(void) {
  int *p = malloc(sizeof(int));
  if (!p) return NULL;
  *p = 42;
  return p; /* allocated storage: lives until free */
}

int main(void) {
  int *p = room();
  if (p) {
    printf("fixed: %d\n", *p);
    free(p); /* exactly once */
  }
  return 0;
}