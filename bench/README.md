# Benchmarking Audio System Performance

These files benchmark the audio processing capacity of a particular set up.
The benchmark runs a test to find the maximum number of test voices it can
play simulateously without getting buffer underruns ("xruns"). The test is
repeated at multiple buffer sizes (`-p` in `jackd`).

The aim is to find out the relative impact of making various changes to the
system configuration:

    * Does setting the CPU governor help?
    * Does disabling X made a difference?
    * What about the TICK frequency or other kernal build flags?

## Running

Run it like so:

    gunzip Bench.gzip
    cd Bench
    sclang benchrun.scd

This will take over 15 min.

Then changing something about your system, and run it again.

#### Output

The final output of the test look like like:

    64 ==> 79 voices, [ 78, 78, 80 ]
    128 ==> 86 voices, [ 83, 88, 87 ]
    256 ==> 94 voices, [ 95, 92, 96 ]
    512 ==> 103 voices, [ 103, 103, 103 ]
    1024 ==> 107 voices, [ 107, 106, 108 ]

This shows, for various period sizes, the average number of voices that
can be run without Xruns. The numbers in brackets are the individual results
from three runs.

## Notes

#### Voices

The voice measured doesn't really matter all that much, but it is a simple
8 UGen voice modeled after `PolyPerc` from the `norns` universe. Your voices
or patch may be more or less complicated, and use different UGens... but you
can expect your results to scale as the benchmark voice does.

#### Disk Recorder

During the test, a disk recorder is started so that `scsynth` will have that
load in the mix. It was added as I/O activity is distinctly different than
straight audio computation... and it is also a likely common part of many
setups.

#### Num. Periods

I original explored the results for various valus of `-n`, the number of
periods used in `jackd`. It turned out that values of 3 or 4 were no different
than 2.  So, I stuck with 2, and just varied the period size (`-p`).

#### Period Size

As expected, period size has an effect on the number of voices that can be
computed, but effect isn't linear in size, it is linear in log2(size). This is
as expected: Each doubling of the period size effectively removes only a
constant amount of overhead from the previous size.

Of course, doubling the period double the latency... so at some point the
trade-off of latency vs. number of voices gets pretty bad if you are worried
about real-time responsiveness! Hence, the test only tries sizes from 64 to
1024 - corresponding to 2.7ms to 42.7ms latency at 48kHz.

#### Jackd

This script launchs `jackd` at various period sizes. It uses a rather
convoluted method to launch it so that it can find out of `jackd` reports an
XRuns. This is because, alas, reading from SuperCollider's `Pipe` object is
synchronous and can't be used within a `Routine` wihtout blocking all of
`sclang`.

#### XRun Seeking

The test tries first 50 voices, then 100, and keeps doubling until it gets
XRuns. Then it seeks back, doing binary search, to find point at which it can
run without XRuns, but no further. You can see this in the output:

    going to play 50 BenchTones...good.
    going to play 100 BenchTones...xrun!
    going to play 75 BenchTones...good.
    going to play 87 BenchTones...xrun!
    going to play 81 BenchTones...good.
    going to play 84 BenchTones...good.
    going to play 85 BenchTones...xrun!
    Max voices without xruns: 84

#### Pauses

The script, alas, has several spots whree it must wait for a short period of
time. This is due mostly to way `jackd` must be started, and the method of
looking for XRuns.



