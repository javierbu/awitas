#!/bin/sh
opkg update
opkg remove wpad-basic-wolfssl dnsmasq
opkg install coreutils-shuf wpa-supplicant coreutils-timeout bash wpa-cli procps-ng-pkill dnsmasq-full  hostapd hostapd-utils airmon-ng aircrack-ng pciutils usbutils lighttpd lighttpd-mod-cgi lighttpd-mod-auth lighttpd-mod-redirect lighttpd-mod-access iptables-nft iptables-mod-nat-extra