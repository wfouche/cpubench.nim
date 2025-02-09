# cpubench.nim

```
num_threads = 4
counter = 29992788380
duration_ms = 10005
dop = 2.0
ghz = 2.998
num_cores = 2
```

```
#include <stdint.h>

int64_t countDownToZero(int64_t n) {
    while (n) {
        n -= 1;
    }
    return n;
}
```

```
// https://godbolt.org, x86-64 gcc 14.2:  -O countdown.c 
countDownToZero:
        testq   %rdi, %rdi
        je      .L2
.L3:
        subq    $1, %rdi
        jne     .L3
.L2:
        movl    $0, %eax
        ret
```

```
// https://godbolt.org, ARM64 gcc 14.2.0:  -O countdown.c 
countDownToZero(long):
        cbz     x0, .L2
.L3:
        subs    x0, x0, #1
        bne     .L3
.L2:
        mov     x0, 0
        ret
```