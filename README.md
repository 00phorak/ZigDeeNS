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
