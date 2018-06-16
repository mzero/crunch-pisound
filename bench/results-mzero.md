# Results from `mzero@`'s system:

### System

* Distro: Raspian Stretch Lite
* Kernel: Linux 4.14.34-v7+ #1110 SMP Mon Apr 16 15:18:51 BST 2018 armv7l GNU/Linux
* RaspberryPi 3b
* Pisound: server 1.02, firmware 1.01
* SuperCollider: 3.9.3 (Built from branch '3.9' [f61c21d3d], w/o GUI or IDE)

### Basic

Fresh boot, `ssh`'d in:

    64 ==> 42 voices, [ 43, 45, 39 ]
    128 ==> 47 voices, [ 49, 48, 45 ]
    256 ==> 50 voices, [ 50, 47, 52 ]
    512 ==> 52 voices, [ 53, 51, 52 ]
    1024 ==> 54 voices, [ 53, 54, 55 ]

### Performance Governor

Ran:

    & echo performance | sudo tee /sys/devices/system/cpu/cpu1/cpufreq/scaling_governor
    # the Pi has only one governor, changing one changes them all

results:

    64 ==> 79 voices, [ 78, 78, 80 ]
    128 ==> 86 voices, [ 83, 88, 87 ]
    256 ==> 94 voices, [ 95, 92, 96 ]
    512 ==> 103 voices, [ 103, 103, 103 ]
    1024 ==> 107 voices, [ 107, 106, 108 ]

### Disabling X & VNC

Ran:

    & sudo systemctl stop vncserver-x11-serviced.service  lightdm.service

results:

    64 ==> 83 voices, [ 80, 85, 83 ]
    128 ==> 86 voices, [ 84, 88, 87 ]
    256 ==> 94 voices, [ 93, 95, 93 ]
    512 ==> 101 voices, [ 103, 101, 100 ]
    1024 ==> 106 voices, [ 107, 107, 105 ]

Not really all that different than with them running.

