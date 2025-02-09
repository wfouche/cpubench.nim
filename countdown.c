#include <countdown.h>

int64_t countDownToZero(int64_t n) {
  while (n) {
    n -= 1;
  }
  return n;
}
