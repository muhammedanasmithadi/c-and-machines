#include <stdio.h>

int add(int a, int b) {
  return a + b;
}

int main(void) {
  printf("add: %d\n", add(40, 2));
  return 0;
}
