#include <countdown.h>

long countDownToZero(long n) {
  while (n) {
    n -= 1;
  }
  return n;
}
