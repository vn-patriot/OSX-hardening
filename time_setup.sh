#! /bin/sh

systemsetup -setnetworktimeserver tic.orau.org
echo "server toc.orau.org" >> /etc/ntp.conf
echo "server time.apple.com" >> /etc/ntp.conf
