import std/cpuinfo
import std/monotimes
import std/cmdline
import std/os
import times
import system
import strutils

const 
    max_cpus = 256

var
    timings: array[max_cpus, int64]
    threads: array[max_cpus, Thread[int]]
    countdown_value: int64
    duration_ms: int64
    threads_waiting: uint8 = 1

let
    num_procs = countProcessors()

{.compile("countdown.c", "-std=c99 -I. -c -O").}

func countDownToZero(n: int64): int64 {.importc: "countDownToZero".}

proc countDownToZeroInMillis(n: int64): int64 =
    let startTime = getMonoTime()
    discard countDownToZero(n)
    return (getMonoTime()-startTime).inMilliseconds

proc calibrateMainLoop(): (int64, int64) =
    let target_duration_ms: int64 = 10 * 1000
    var current_counter: int64 = 2
    var current_duration_ms: int64 = 0
    while true:
        current_duration_ms = countDownToZeroInMillis(current_counter)
        if current_duration_ms < 100:
            current_counter *= 2
        else:
            echo "  ", current_counter, " ", current_duration_ms
            if abs(target_duration_ms-current_duration_ms) < 50:
                break
            var current_counter2: float = current_counter * target_duration_ms / current_duration_ms
            current_counter = current_counter2.toInt()
    return (current_counter, current_duration_ms)

proc threadTask(threadId: int) {.thread.} = 
    while (threads_waiting == 1):
        sleep(1)
    timings[threadId] = countDownToZeroInMillis(countdown_value)

proc cpubench =
    echo "num_threads = ", num_procs

    (countdown_value,duration_ms) = calibrateMainLoop()

    echo "counter = ", countdown_value
    echo "duration_ms = ", duration_ms

    for i in 0..<num_procs:
        createThread(threads[i], threadTask, i)

    sleep(3000)

    threads_waiting = 0

    for i in 0..<num_procs:
        threads[i].joinThread()

    var tsum: int64 = 0
    for i in 0..<num_procs:
        tsum += timings[i]

    let dop: float = (tsum.toFloat() / num_procs.toFloat()) / duration_ms.toFloat()
    let ghz: float = countdown_value.toFloat() / 1000000.0 / duration_ms.toFloat()

    echo "dop = ", dop.formatFloat(ffDecimal,1)
    echo "ghz = ", ghz.formatFloat(ffDecimal,3)
    echo "num_cores = ", dop.formatFloat(ffDecimal,1), " (", num_procs, ")"

var iterations: int = 1

if paramCount() == 1:
    iterations = parseInt(paramStr(1))

for i in 0..<iterations:
    if i > 0: echo ""
    cpubench()