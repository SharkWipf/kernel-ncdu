# kernel-ncdu
A hacky way to visualize compile times of each section of the Linux kernel.

## Usage:
- Get the script
- Compile a kernel with the following command to generate a log file with timestamps for each compiled file:
    - This script will only produce accurate results when you compile with -j1! Anything else will produce only gibberish.
```bash
make clean; make -j1 | kernel-ncdu.sh | tee times.log
```
- Once it's done, run `kernel-ncdu.sh times.log`
- After a few seconds you should be greeted with a fully interactive time analyzer

Note: You can skip logging to file by running the command like so:
```bash
make clean; make -j1 | kernel-ncdu.sh | kernel-ncdu.sh /dev/stdin
```
However, considering how long it takes to compile a kernel with -j1, it is recommended to log it to a file first, so you don't have to wait too long if you accidentally close the program.

![Animation showing how the tool works](https://user-images.githubusercontent.com/751205/66029001-a013f780-e4fe-11e9-865c-d2b7d5b8084d.gif)

Please be aware that this script is a big, inefficient hack, and by no means meant to be a stable product.
It should do the job, but don't expect too much.

