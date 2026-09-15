#include <stdio.h>

/* a pointer that outlives its object: undefined behavior by design */

typedef struct {
  char name[16];
  int points;
} Entry;

Entry *winner(void) {
  Entry local;
  local.points = 7;
  return &local;
}

int main(void) {
  Entry *w = winner();
  printf("%d\n", w->points);
  return 0;
}