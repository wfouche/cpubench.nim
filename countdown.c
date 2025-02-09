#include <countdown.h>

long countDownToZero(int64_t n) {
  while (n) {
    n -= 1;
  }
  return n;
}
