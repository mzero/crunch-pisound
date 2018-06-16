
These are instructions for building a stand alone, headless, music computer
based on the Pisound audio card and a RaspberryPi 3.

I use this set up in my
live performance rig where it does all of the following without breaking a
sweat:

* Audio effects
    * stutter gate (beat sync'd)
    * full sweep LPF & HPF filters
    * multiple delay lines (beat sync'd)
    * reverb
    * 3 band parametric EQ
    * volume controls
* MIDI processing
    * CC controls for all audio effect parameters
    * MIDI clock master w/tempo controls and display on controller
    * routing CCs from control surface to ext. synths
    * routing keyboard input to different ext. synths
    * set and song timers


The aims of the set up are:

* Standard Linux distribution for a Pi (Raspian)
* Minimal installation (based on Raspian Lite)
* Runs headless at gigs, with minimal system overhead
* Ability to use X & VNC when connected via a network
* Support for Puredata and SuperCollider.
* Low audio latency without excessive fiddly tuning.
    * With all of the above active, I get ~5ms input to output delay!

## Assumptions

* You know what a terminal is
* You have some passing experience with Linux
* You have a Mac
    * You could use Windows or Linux, but I don't have detailed instructions
      for some bits. Most of the instructions are exactly the same.
* You are brave


----

# Get the Hardware

#### Pisound from Blokas

* sound card: https://blokas.io/pisound
* also worth getting the optional case they make

#### RaspberryPi

* https://www.raspberrypi.org/products/
* either **3 Model B+** or a **3 Model B**

#### SD Card

* Install takes just under 2GB, so go 8GB or more.

#### Misc

* SD Card reader if your computer doesn't have an SD Slot
* Free Ethernet port - either on an Ethernet switch, or on your computer.
    * If on your computer, you must be able to get onto the Internet while
      that jack is in use by the Pi - so either via WiFi, or your computer
      has two Ethernet jacks.
    * A USB Ethernet adpater is often just the ticket.
* Ethernet cable


# Set up the Image

#### 1. Download Raspian "lite" image

Download from here: [https://www.raspberrypi.org/downloads/raspbian/](https://www.raspberrypi.org/downloads/raspbian/)

You want the version named **"RASPBIAN STRETCH LITE"**

_You can use the "DESKTOP" image, and it will
have tons of software already installed and set up.... but its not small by
any means. Most of it has nothing to do with running the Pi as a music
computer. Further, some of it might well slow the unit down._


#### 2. Burn the image to the sdcard

_Note: There are several methods listed on Raspberry Pi site for [installing
the image](https://www.raspberrypi.org/documentation/installation/installing-images/)
onto the SD Card. You can use any of them... but most involve downloading
and installing a program on your personal computer. But on a Linux or OS X
machine you already have all the tools on the command line. And since you
need to be familiar with the command line anyway... I just do it this way._

**These instructions are for OS X** -- For other systems, see the
[Raspberry Pi site](https://www.raspberrypi.org/documentation/installation/installing-images/)

Before you insert your SD Card... (If you already did, eject it in the Finder,
then physically remove it.)

Open terminal run:

    diskutil list | grep ^/dev

You'll see something like:

    /dev/disk0 (internal, physical):
    /dev/disk1 (synthesized):

These are the disk volumes on your computer. You may have more or just one.

Now, insert your SD Card into a SD Card reader, and into your computer. If your
computer asks you about formatting it, just choose "Ignore".

Run the same command again:

    diskutil list | grep ^/dev

You should see one more line:

    /dev/disk0 (internal, physical):
    /dev/disk1 (synthesized):
    /dev/disk2 (internal, physical):

Note which is the new one. In this case `/dev/disk2` is the new disk,
and represents the SD Card. It's disk number is `2`.  The disk number for your
SD Card may be different.

In the commands that follow, when you see `disk#` replace the `#` with your
disk number.

Now run the following:

    diskutil unmountDisk /dev/disk#
    cd ~/Downloads
    unzip ~/Downloads/2018-04-18-raspbian-stretch-lite.zip
    sudo dd bs=1m if=2018-04-18-raspbian-stretch-lite.img of=/dev/rdisk# conv=sync
    rm ~/Downloads/2018-04-18-raspbian-stretch-lite.img

Your download file might be named differently. Also take careful note that
on the second line there is a sneaky `r` in front of `disk#`.

This will take a bit of time. If you are worried, type `CTRL-T` and `dd` will
print some cryptic indication of it's progress.

When it is done, OS X will automatically mount the newly imaged disk.

_Do not eject the SD Card yet..._

#### Enable SSH in the Image

This is very important so that you can connect into the Pi when it boots
headless.

After the burning, the disk will be mounted at `/Volumes/boot`. Run this:

    touch /Volumes/boot/ssh

Now eject the SD Card, either in the Finder, or from your terminal, like so:

    diskutil eject /dev/disk#


# First Boot

The aim at this stage is to get the Pi up and booted, on the network, and
to be sure you have connectivity to it.

#### Network Preparation

If your computer uses wired ethernet, and you have a spare Ethernet jack
on your hub or switch or router, you can just plug the Pi into that.

If not, you can connect the Ehternet port on the Pi to the Ethernet port on
your computer (or perhaps a USB Ethernet adpater on your computer), sharing
access to the internet you get via WiFi. To do this:

* Ensure you have Internet connectivity
* Connect your USB Ethernet adapter if you need to
* Apple menu > **System Preferences** > Sharing icon
* Select **Internet Sharing** (it won't check, that's okay)
* "Share your computer from" should be showing your Internet connection
* "To computer using": check the Ehternet port you'll use to connect to the Pi
* Now check the box next to **Internet Sharing**
* Click **Start** in the dialog that appears.

#### Set up the Pi

* Unpack the Pi:
  Don't put it in any case yet. Don't power it on. Don't attach heat sinks
  (ever). Place it on something non-conductive (paper? the box it came in?)
* Insert the SD Card
* Connect an Ethernet cable between the Pi and your computer.
* Now plug in the power.

#### Log In

Back on your computer, in the terminal, run:

    ssh pi@raspberrypi.local

You'll get asked if you trust this new host. Type `yes` and hit return.

Then you'll get asked for the password. It's `raspberry`.

```
The authenticity of host 'raspberrypi.local (192.168.2.2)' can't be established.
ECDSA key fingerprint is SHA256:13XNzKJHbLc3wizLJMlrMbhtnj2cRRcQXdF9iG4umUE.
Are you sure you want to continue connecting (yes/no)? yes
Warning: Permanently added 'raspberrypi.local,192.168.2.2' (ECDSA) to the list of known hosts.
pi@raspberrypi.local's password:
Linux raspberrypi 4.14.34-v7+ #1110 SMP Mon Apr 16 15:18:51 BST 2018 armv7l

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.

SSH is enabled and the default password for the 'pi' user has not been changed.
This is a security risk - please login as the 'pi' user and type 'passwd' to set a new password.

pi@raspberrypi:~ $
```

You're in!


#### Update and Install Basics

This will ensure you have the latest version of all the installed packages.

    sudo apt-get update
    sudo apt-get dist-upgrade

Depending on how old the image you downloaded is, this could be quick or take
some time.

Now install the minimal things needed to be able to run a graphical desktop.
You'll use this graphical desktop when you connect to the Pi from your computer.
This makes working in PureData or SuperCollider nice. Because we're seting it
up minimal, when you run headless, the desktop will not be running, and the
audio programs will run without visual UI.

Run these two commands. Don't be clever and combine them:

    sudo apt-get install --no-install-recommends \
        screen vim \
        git make \
        xserver-xorg xinit \
        realvnc-vnc-server
    sudo apt-get install raspberrypi-ui-mods

Swap `emacs` for `vim` if you prefer. You'll get asked if you want to proceed
('Y', of course). These two commands will download well over a hundred packages.

Run:

    sudo raspi-config

You can move around this menu structure setting things. Here are a few
you need to set:

    1. Change User Password

change it now! To something you'll remember.

Then make these settings, using arrows to select options, tab to move between
menus and buttons, and enter to select:

    3. Boot Options
        B1 Desktop / CLI
            B3 Desktop

    4. Localisation Options
        I2 Change Timezone
            -- pick your timezone

    4. Localisation Options
        I4 Change Wi-fi Country
            -- pick your country

    5 Interfacing Options
        P3 VNC
            Yes    (use arrow keys to select)

    7. Advanced Options
        A3 Memory Split
            16

    7. Advanced Options
        A5 Resolution
            1600x1200   (or whatever you like, but the default is too small!)

Then `[tab]` key to `Finish`, hit `return`, then select `Yes` to reboot.


# Graphic Login

On your computer, install [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/)

Run it and connect to your Pi (`raspberrypi.local`). You'll need to enter
login information twice - once to RealVNC... and then once to the Pi screen
that comes up.

Play around with the desktop if you like. Customize the colors and background
image.

From the big raspberry icon on the task bar, Shutdown the pi...

----

## Whew!

You've got the Pi set up as a minimal system that can have a desktop if you like, or will just boot up without a display if needed.

That was the hard part... getting audio set up is going to be much easier!

----

# Assemble the Pisound

Follow the instructions on Blokas' web site: [Getting Started](https://blokas.io/pisound/docs/).

If assembling the case, pay attention to the height of the standoffs - there
are short and long ones, and the short ones go on the bottom. Also the bottom
plate may need to be fliped over as the two sides aren't exactly the same.
Try fitting the long side pieces in before screwing all down to see which way
it goes.

Leave the SD Card in - it is really hard to insert it once you start assembling
the case.

Once it is all assembled, connect the network again, then power it back on.

# Pisound Software

#### 1. Install Pisound Drivers

Blokas provides an installer script. They have you download it directly into
the shell so it runs immediately. That always makes me nervous, so I do it this
way:

Log into the Pi via RealVNC. On the task bar, click the screen icon (has ">_"
symbol) to open a shell. Run this:

    curl -O https://blokas.io/pisound/install-pisound.sh
    less install-pisound.sh   # look at it and see if it sensible
    sh install-pisound.sh
    rm install-pisound.sh

If you are adventurous, you can do it in one step:

    curl https://blokas.io/pisound/install-pisound.sh | sh

In either case, you may have to enter your password, since installation runs
with `sudo`.

At the end of the script it suggests:

    Now you may run sudo pisound-config to customize your installation!

**Hold off!**, we will install the music software manually to ensure it is
minimal.

#### 2. Verify Drivers

You can verify that the drivers are installed, and that the Pisound hardware
is all operating with the O.S.

Run this to see the list of audio output devices:

    aplay -l

You should see this, with **pisound** listed in the list:

    **** List of PLAYBACK Hardware Devices ****
    card 0: ALSA [bcm2835 ALSA], device 0: bcm2835 ALSA [bcm2835 ALSA]
      Subdevices: 7/7
      Subdevice #0: subdevice #0
      Subdevice #1: subdevice #1
      Subdevice #2: subdevice #2
      Subdevice #3: subdevice #3
      Subdevice #4: subdevice #4
      Subdevice #5: subdevice #5
      Subdevice #6: subdevice #6
    card 0: ALSA [bcm2835 ALSA], device 1: bcm2835 ALSA [bcm2835 IEC958/HDMI]
      Subdevices: 1/1
      Subdevice #0: subdevice #0
    card 1: pisound [pisound], device 0: PS-2DES12E snd-soc-dummy-dai-0 []
      Subdevices: 1/1
      Subdevice #0: subdevice #0

Run this to see the list of audio input devices:

    arecord -l

You should see:

    **** List of CAPTURE Hardware Devices ****
    card 1: pisound [pisound], device 0: PS-2DES12E snd-soc-dummy-dai-0 []
      Subdevices: 1/1
      Subdevice #0: subdevice #0

Run this to see the list of MIDI devices:

    aconnect -l

You should see this:

    client 0: 'System' [type=kernel]
        0 'Timer           '
        1 'Announce        '
    client 14: 'Midi Through' [type=kernel]
        0 'Midi Through Port-0'
    client 20: 'pisound' [type=kernel,card=1]
        0 'pisound MIDI PS-2DES12E'


If you have some USB MIDI devices plugged in, you'll see them in that list, too!


# Music Apps

### PureData

Install with:

    sudo apt-get install --no-install-recommends puredata gem

Note: This is a _much_ smaller install than what the `pisound-config` installs.
For some unknown reason, the package for `gem` recommends pulling in a full
PDF rendering system! Hence, the `--no-install-recommends`.


### SuperCollider

You have two choices... install version 3.7.0 which is in the package repos.
This is easy, but a little older.

Or compile it yourself, but that's a bit harder and will take an hour or more.

#### Just install it...

Install with

    sudo apt-get install --no-install-recommends supercollider

Note: This is a _much_ smaller install than what the `pisound-config` installs.

You will get a dialog box with a lot of text, asking you, at the end
"Enable realtime process priority?". Choose

    Yes

#### Set up

Unlike PureData, which can talk directly to the `alsa` audio drivers,
SuperCollider talks to `jackd`, which in turn talks to `alsa`. You can let
SuperCollider handle starting and stopping `jackd` for you, but you need to
set it up.

Edit (`vi` or `emacs` or `nano`) the file `~/.jackdrc` to have the following
single line:

    /usr/bin/jackd -R -P 75 -d alsa -d hw:pisound -r 48000 -n 2 -p 64 -s

#### Run it

    scide

Once running, you need to boot a server: From the **Language** menu, choose
**Boot Server**. You'll see some text which should let you know that `jackd`
is running with `ALSA`.

Then type some SuperCollider code into the big, **Untitled** window, select
it, and choose **Language** menu > **Evalutate Selection, Line, or Region**.
(Or type `[CTRL+Return]`)

Try this lovely snippet from Fredrik Olofsson:

> play{q=SinOsc;a={|x...y|perform(x,\ar,*y)};Splay ar:a.(CombN,c=a.(q,0,a.(Blip,1/f=(1..8),888/a.(q,1/88,0,2,3).ceil*a.(Duty,a.(q,1/8)>0+2*1/8,0,Dseq([8,88,888],inf)))*188),1,8-f/8,8)/8+a.(CombN,a.(GVerb,a.(BPF,8*e=c.mean,88,1/8),88),1,1)+a.(q,88,0,a.(q,0,e)<0/88)}// #SuperCollider

 He's [@redFrik on twitter](https://twitter.com/redFrik), and he posts many
 great short compositions you can play in SuperCollider.

To stop, **Language** > **Stop**. (or just `[CTRL+.]`.)

If you want to test input effects processing, try this:

    {
        var fast = SinOsc.kr(12) * 2;      // +/- 2 semitones at 12Hz
        var slow = SinOsc.kr(0.2) * 24;    // +/- 2 octaves at 1/5Hz
        var center = 60;                   // around middle C
        var filtFreq = (fast + slow + center).midicps;

        var input = SoundIn.ar();
        var resonated = Resonz.ar(input, filtFreq, bwr:0.15);
        var reverbed = FreeVerb.ar(resonated, room:0.8);

        reverbed   // last thing returned is played out
    }.play

----

# Done!

#### Play music, have fun, and let me know how it went!

- Mark

----

----

# Things Still to Figure Out and Add


#### WiFi

two ways to set up WiFi

    - raspi-config if you want it to connnect
    - pisound-config if you want the button to launch a hotspot


* set up static ip by editing /etc/dhcpcd.conf  (optional):

    interface eth0

    static ip_address=192.168.42.6/24
    static routers=192.168.42.1
    static domain_name_servers=8.8.8.8 8.8.4.4

    * reboot, re-log in

#### Nicer terminal

sakura


#### Setting up the Btn for SuperCollider scripts

#### The default PureData patches don't work with the Button

[] Pressing the button after installing PureData fails because it loads the
wrong file. It tries to load

    /usr/local/puredata-patches/GarageBeat/_main.pd

But that patch needs to start with:

    /usr/local/puredata-patches/GarageBeat/0_START.pd


#### Turn off the Screen Saver

use the menu > Preferences > ScreenSaver setting

or, maybe also

edit `~/.config/lxsession/LXDE-pi/autostart`, comment out the `@xscreensaver`
line like so:

    @lxpanel --profile LXDE-pi
    @pcmanfm --desktop --profile LXDE-pi
    #@xscreensaver -no-splash
    @point-rpi

#### note about cron & anacron

#### need to measure if auto login really eats any significant CPU when headless

#### should figure out if changing the memory split really matters or not

#### note about raspi-config internationalization

- either don't do it it, or just set on

#### add `pi` to sudoers?


