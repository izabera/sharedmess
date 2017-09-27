#include <stdio.h>

void leak1();
void leak2();

int main() {
  for (int i = 0; i < 5; i++) {
    puts("calling leak1"); leak1();
    puts("calling leak2"); leak2();
  }
}
