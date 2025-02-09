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
