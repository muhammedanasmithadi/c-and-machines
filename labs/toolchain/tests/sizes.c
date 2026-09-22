#include <stdio.h>

int main(void) {
  printf("char=%zu int=%zu long=%zu ptr=%zu\n",
         sizeof(char), sizeof(int), sizeof(long), sizeof(void *));
  return 0;
}
