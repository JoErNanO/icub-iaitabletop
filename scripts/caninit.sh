#!/bin/sh

# installare libsocketcan download tar -xjvf pippo  ./configure, make e make install
# installare canutils download tar -xjvf pippo  ./configure, make e make install

#try to enlarge net layer max RX buf
#sudo echo 400000 > /proc/sys/net/core/rmem_max

#set to 1mbps. If the kernel is configured with bit calculation option it is easier
# sudo modprobe esd_usb2
# on ESD usb2 drv the BPR reg should be 0x804d0002
canconfig can0 bittiming  prop-seg 2 phase-seg1 12 phase-seg2 5 sjw 1 brp 3 tq 50
ifconfig can0 up

#iface up
#canconfig can0 start
