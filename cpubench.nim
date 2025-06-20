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

var
    target_duration_ms: int64 = 10000
    delta_ms: int64 = 100

let
    num_procs = countProcessors()

{.compile("countdown.c", "-std=c99 -I. -c -O").}

func countDownToZero(n: int64): int64 {.importc: "countDownToZero".}

proc countDownToZeroInMillis(n: int64): int64 =
    let startTime = getMonoTime()
    discard countDownToZero(n)
    return (getMonoTime()-startTime).inMilliseconds

proc calibrateMainLoop(): (int64, int64) =
    var current_counter: int64 = 2
    var current_duration_ms: int64 = 0
    var iterations: int = 0
    while true:
        current_duration_ms = countDownToZeroInMillis(current_counter)
        if current_duration_ms < 100:
            current_counter *= 2
        else:
            iterations += 1
            echo "  ", current_counter, " ", current_duration_ms
            if abs(target_duration_ms-current_duration_ms) <= delta_ms:
                break
            var current_counter2: float = current_counter * target_duration_ms / current_duration_ms
            current_counter = current_counter2.toInt()
            if iterations == 10:
                return (0,0)
    return (current_counter, current_duration_ms)

proc threadTask(threadId: int) {.thread.} = 
    while (threads_waiting == 1):
        sleep(1)
    timings[threadId] = countDownToZeroInMillis(countdown_value)

proc cpubench =
    echo "num_threads = ", num_procs

    (countdown_value,duration_ms) = calibrateMainLoop()
    if countdown_value != 0:
        echo "counter = ", countdown_value
        echo "duration_ms = ", duration_ms

        for i in 0..<num_procs:
            createThread(threads[i], threadTask, i)

        sleep(3000)

        threads_waiting = 0

        for i in 0..<num_procs:
            threads[i].joinThread()
            #echo timings[i]

        var tsum: int64 = 0
        var tsum2: int64 = 0
        for i in 0..<num_procs:
            tsum += timings[i]
            tsum2 += duration_ms

        let dop: float = (tsum2.toFloat() / tsum.toFloat()) * num_procs.toFloat() 
        #et ghz: float = countdown_value.toFloat() / 1000000.0 / duration_ms.toFloat()

        echo "dop = ", dop.formatFloat(ffDecimal,1)
        #cho "ghz = ", ghz.formatFloat(ffDecimal,3)
        echo "num_cores = ", dop.formatFloat(ffDecimal,1), " (", num_procs, ")"
    else:
        echo ""
        echo "Unstable computer environment detected, exiting."

let iterations: int = 1

if paramCount() == 2:
    target_duration_ms = parseInt(paramStr(1))
    delta_ms = parseInt(paramStr(2))

for i in 0..<iterations:
    if i > 0: echo ""
    cpubench()
