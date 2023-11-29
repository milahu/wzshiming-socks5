https://github.com/wzshiming/socks5/issues/6

bind: address already in use

im getting this error after killing and restarting the socks5 server

```
$ ./cmd/socks5/socks5
[socks5] 2023/11/29 17:40:38 listen tcp :1080: bind: address already in use
```

maybe the server is missing some cleanup code, to close all connections

> after killing and restarting the socks5 server

im killing the server with control-c (sigint)
so the server should have enough time for cleanup

run.sh

```sh
#!/usr/bin/env bash

set -e

netstat_out="$(netstat -nap 2>/dev/null | grep -w 1080 || true)"
if [ -n "$netstat_out" ]; then
  echo "error: address already in use"
  echo "$netstat_out"
  exit 1
fi

cd cmd/socks5/ &&
go build &&
cd ../.. &&
./cmd/socks5/socks5 &
socks5_pid=$!;
echo socks5_pid: $socks5_pid;
sleep 1;
curl --proxy socks5h://localhost:1080 https://httpbin.org/ip;
kill $socks5_pid
```

```
$ ./run.sh 
socks5_pid: 371297
{
  "origin": "xxxxxxxxxxxxx"
}

$ ./run.sh 
error: address already in use
tcp6       0      0 :::1080                 :::*                    LISTEN      371359/./cmd/socks5 
tcp6       0      0 ::1:60936               ::1:1080                TIME_WAIT   -                   
```

problem: the worker process 371359 keeps running
after then main process 371297 was killed
