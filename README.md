# ZigDeeNS - Zig DNS

## run (or build)
Windows: to run or build the executable, you have to link c library (if present on system); hence the -lc parameter
```bash
zig run -lc src/main.zig
# or
zig build-exe -lc src/main.zig
````
Unix: no need to link C, usually present on system
```bash
zig run src/main.zig
# or
zig build-exe src/main.zig
````

## verify its working
Once the app is running, you can verify it's working by sending UDP messages to 2048 port
```bash
echo "should print on std" | nc -u 127.0.0.1 2048
```

## testing

For simple tests, use:
```bash
zig test /path/to/file.zig
````

For build testing, use:
```bash
zig build test --summary all
```

from build.zig. To link all the tests, I used this snippet in main.zig
```zig
comptime {
  std.testing.refAllDecls(@This());
}
```
### generate testing packets
```bash
nc -u -l 1053 > query_packet
# in different shell
dig +retry=0 -p 1053 @127.0.0.1 +noedns google.com
# back to this, once query packet is generated
nc -u 8.8.8.8 53 < query_packet > response_packet
# verify contents with hexdump
hexdump -C query_packet
hexdump -C response_packet

```
