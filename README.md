# cpubench.nim

```
num_procs = 4
counter = 29992788380, duration_ms = 10005
dop = 2.0
ghz = 2.998
num_cores = 2
```

```
// https://godbolt.org/
//
long countDownToZero(long n) {
    while (n) {
        n -= 1;
    }
    return n;
}
```

```
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