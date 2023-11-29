#!/usr/bin/env bash

set -e

netstat_out="$(netstat -nap 2>/dev/null | grep -w 1080 || true)"
if [ -n "$netstat_out" ]; then
  echo "error: address already in use"
  echo "$netstat_out"
  #if true; then
  if false; then
    exit 1
  else
    echo "killing worker procs using port 1080"
    netstat -nap 2>/dev/null | grep -w 1080 | awk '{ print $7 }' | cut -d/ -f1 | grep -vxFe - | xargs -r kill
  fi
fi

cd cmd/socks5/ &&
go build &&
cd ../.. &&
./cmd/socks5/socks5 &
socks5_pid=$!;
echo socks5_pid: $socks5_pid;
sleep 2;
if true; then
#if false; then
  # socks5
  curl --proxy socks5://localhost:1080 https://httpbin.org/ip;
else
  # socks5h
  curl --proxy socks5h://localhost:1080 https://httpbin.org/ip;
fi
kill $socks5_pid
