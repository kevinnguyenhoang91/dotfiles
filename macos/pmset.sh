#!/bin/bash

# Battery Power

sudo pmset -b lidwake 0
sudo pmset -b standbydelayhigh 60
sudo pmset -b standbydelaylow 30
sudo pmset -b standby 1
sudo pmset -b proximitywake 0
sudo pmset -b ttyskeepawake 0
sudo pmset -b highstandbythreshold 50
sudo pmset -b powernap 0
sudo pmset -b gpuswitch 2
sudo pmset -b hibernatefile var/vm/sleepimage
sudo pmset -b hibernatemode 3
sudo pmset -b displaysleep 3
sudo pmset -b sleep 5
sudo pmset -b tcpkeepalive 0
sudo pmset -b halfdim 1
sudo pmset -b acwake 0
sudo pmset -b lessbright 1
sudo pmset -b disksleep 5

# AC Adapter
sudo pmset -a lidwake 0
sudo pmset -a standbydelayhigh 300
sudo pmset -a standbydelaylow 60
sudo pmset -a standby 1
sudo pmset -a proximitywake 0
sudo pmset -a ttyskeepawake 0
sudo pmset -a hibernatemode 3
sudo pmset -a powernap 0
sudo pmset -a gpuswitch 2
sudo pmset -a hibernatefile var/vm/sleepimage
sudo pmset -a highstandbythreshold 50
sudo pmset -a womp 0
sudo pmset -a displaysleep 15
sudo pmset -a networkoversleep 0
sudo pmset -a sleep 20
sudo pmset -a tcpkeepalive 0
sudo pmset -a halfdim 0
sudo pmset -a acwake 0
sudo pmset -a disksleep 10
