#!/bin/bash

# The more you enable, the more stress you put on BIND.
#ENABLE_YOYO=1
#ENABLE_ZEUSTRACKER=1
#ENABLE_MALWAREDOMAINS=1
#ENABLE_CAMELEON=1
#ENABLE_STEVENBLACK=1
#ENABLE_HOSTSFILE=1


MASTER_FILE="/data/bind/etc/master_blacklist"
BLACKLIST_PATH="/data/bind/etc/blacklist.d"
RAW_BLACKLIST_PATH="/data/bind/etc/blacklist.raw"


# yoyo: Already comes in plain text format.
YOYO_FILE="$BLACKLIST_PATH/yoyo.txt"
if [[ $ENABLE_YOYO -eq 1 ]]; then
  echo "[*] Updating DNS blacklist: [yoyo]"
  wget -q -O $YOYO_FILE "https://pgl.yoyo.org/as/serverlist.php?hostformat=nohtml&showintro=0"
else
  if [ -e $YOYO_FILE ]; then
    rm $YOYO_FILE
  fi
fi


# zeustracker: Tracks the ZeuS botnet
ZEUSTRACKER_FILE="$BLACKLIST_PATH/zeustracker.txt"
if [[ $ENABLE_ZEUSTRACKER -eq 1 ]]; then
  echo "[*] Updating DNS blacklist: [zeustracker]"
  wget -q -O- https://zeustracker.abuse.ch/blocklist.php?download=domainblocklist \
    | grep -v '#' | grep . > $ZEUSTRACKER_FILE
else
  if [ -e $ZEUSTRACKER_FILE ]; then
    rm $ZEUSTRACKER_FILE
  fi
fi


# malwaredomains: Tracks the ZeuS botnet
MALWAREDOMAINS_FILE="$BLACKLIST_PATH/malwaredomains.txt"
if [[ $ENABLE_MALWAREDOMAINS -eq 1 ]]; then
  echo "[*] Updating DNS blacklist: [malwaredomains]"
  wget -q -O- https://mirror1.malwaredomains.com/files/justdomains \
    | grep -v '#' | grep . > $MALWAREDOMAINS_FILE
else
  if [ -e $MALWAREDOMAINS_FILE ]; then
    rm $MALWAREDOMAINS_FILE
  fi
fi


CAMELEON_FILE="$BLACKLIST_PATH/cameleon.txt"
if [[ $ENABLE_CAMELEON -eq 1 ]]; then
  echo "[*] Updating DNS blacklist: [cameleon]"
  wget -q -O- "http://sysctl.org/cameleon/hosts" \
    | grep -v "#" | tr -s " " | tr "\t" " " | cut -d' ' -f2  \
    | grep . > "$CAMELEON_FILE"
else
  if [ -e $CAMELEON_FILE ]; then
    rm $CAMELEON_FILE
  fi
fi;


# stevenblack: Independently compiled list on GitHub.
STEVENBLACK_FILE="$BLACKLIST_PATH/stevenblack.txt"
if [[ $ENABLE_STEVENBLACK -eq 1 ]]; then
  echo "[*] Updating DNS blacklist: [stevenblack]"
  wget -q -O- https://raw.githubusercontent.com/StevenBlack/hosts/master/hosts \
    | grep -v '#' | grep . | cut -d' ' -f2 > $STEVENBLACK_FILE
else
  if [ -e $STEVENBLACK_FILE ]; then
    rm $STEVENBLACK_FILE
  fi
fi


# hosts-file: Doesn't allow automation. Keep local copy, and update as needed.
# These files are massive, and can clog BIND. Only enable if server is well resourced.
HOSTSFILE_PATH="$RAW_BLACKLIST_PATH/hosts-file.net"
if [[ $ENABLE_HOSTSFILE -eq 1 ]]; then
  echo "[*] Updating DNS blacklist: [hosts-file]"
  for BLACKLIST_FILE in $(ls $HOSTSFILE_PATH); do
    grep -v "#" "$HOSTSFILE_PATH/$BLACKLIST_FILE" | tr -s " " | tr "\t" " " \
    | cut -d' ' -f2 > "$BLACKLIST_PATH/$BLACKLIST_FILE"
  done;
else
  for BLACKLIST_FILE in $(ls $HOSTSFILE_PATH); do
    if [ -e "$BLACKLIST_PATH/$BLACKLIST_FILE" ]; then
      rm "$BLACKLIST_PATH/$BLACKLIST_FILE"
    fi
  done;
fi;


echo "[*] Merging DNS blacklists"
touch "$MASTER_FILE.tmp"
for BLACKLIST_FILE in $(ls $BLACKLIST_PATH); do
  cat "$BLACKLIST_PATH/$BLACKLIST_FILE" | grep -Ev "^#" | grep . >> "$MASTER_FILE.tmp"
done;


echo "[*] Transforming domain master blacklist to BIND zones"
sort -u "$MASTER_FILE.tmp" | sed -r \
  "s/(.*)/zone \"\1\" { type master; notify no; file \"\/data\/bind\/etc\/zones\/blackhole\"; check-names warn; };/g" \
   > "$MASTER_FILE"
rm "$MASTER_FILE.tmp"
