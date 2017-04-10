% Building HaLVMs with Nix
% @dmjio
% April 8th 2017

### <a href="http://github.com/GaloisInc/HaLVM">HaLVM</a>
<!-- Talking points are comments ;) so as not to confuse the pandocs -->
The Haskell Lightweight Virtual Machine

A <a href="http://galois.com">Galois</a> Project

by

<a href="https://github.com/acw">Adam Wick</a>, <a href="https://github.com/elliottt">Trevor Elliott</a>
<!-- Build a trust-worthy operating system based on a microkernel design
     Inspired by work done on House (Haskell operating system)
     Adam gave first presentation in 2006
     Now open-sourced and an experimental platform for OS library design
-->

### Hypervisor
  - Virtualization
  - Manage and share machine resources intelligently across multiple, potentially different hosts.
  - Implementations
    - bhyve, Hypervisor.Framework, KVM, Xen
	  - HaLVM 2.x specifically targets Xen *only*
      - Xen heavily used by AWS

### Components
- halvm-ghc/rts/xen (entry-exit.c, timers, clocks, interrupts, memory management)
    - Manages interaction between Haskell application and Xen layer
- bootloader, openlibm, minlibc, ldkernel, Makefile
- shell scripts (halvm-ghc, halvm-ghc-pkg, halvm-cabal)
- No unix (network, directory)
- HaLVMCore, XenDevice
<!-- Main benefits are reduced attack surface
rts/xen acts a miniature OS
Domains communicate back to Xen specific portion of Linux kernel via hypercalls
ldkernel is a linker script that plays an important role in assembling the microkernel
Nix essentially wraps the Makefile, and make recursively calls into halvm-ghc (ghc fork) to build
HaLVMCore (Haskell bindings to Xen facilities)
XenDevice (Haskell bindings to Disk, NIC, PCI) - Xen virtual devices
There are no POSIX facilities, no users, no pthreads or sockets.
-->

### Getting HaLVM
Updated for GHC 8.0.2

```
λ nix-shell -p haskell.compiler.ghcHaLVM240
λ nix-shell -p haskell.compiler.integer-simple.ghcHaLVM240
```
Available from cache.nixos.org

<!-- HaLVM build / distribution / package maintenance is a pain point, GHC takes a long time to compile.
HaLVM on the Nix cache essentially solves this.
Still a tad difficult to develop with since the entire GHC tree is a single derivation.
At least builds run in an isolated manner w/ nix.
-->


### Hello World
```
λ nixos ~ → cat > Main.hs <<EOF
heredoc> module Main where
heredoc>
heredoc> import Hypervisor.Console
heredoc> import Control.Concurrent
heredoc> import Control.Monad
heredoc>
heredoc> main :: IO ()
heredoc> main = do
heredoc>   () <$ initXenConsole
heredoc>   forever $ do
heredoc>     threadDelay (1000 * 1000)
heredoc>     putStrLn "Hello world!"
heredoc> EOF
```
<!--
Keep it running so the virtual machine doesn't exit
Xen Console allows one to see print statements from a guest
-->

### Building
```
[nix-shell:~]$ halvm-ghc Main.hs -o main
```
<!-- Can use common cabal2nix infrastructure here too. -->
<!-- ELF file that runs as a paravirtualized guest -->

### Xen config
```
[nix-shell:~]$ cat > main.config <<EOF
> name = "main"
> kernel = "main"
> memory = 16
> EOF
```

### Running
```
[nix-shell:~]$ sudo xl create main.config -c
```

### Result
```
[nix-shell:~]$ sudo xl create main.config -c
Parsing config from main.config
Hello world!
Hello world!
Hello world!
C-[
```

### Status
```
[nix-shell:~/halvm-beginning]$ sudo xl list
Name       ID   Mem VCPUs	State	Time(s)
main       28    64   1    -b----    0.1
```

### Cleaning up
```
[nix-shell:~]$ sudo xl destroy main
```

### ldkernel
Where it all comes together
```
ghc -pgml ldkernel
```

### HaNS
- [HaNS - https://github.com/GaloisInc/HaNS](https://github.com/GaloisInc/HaNS)
- RFC-compliant Haskell Network Stack
  - From Layer 2 (Ethernet) to Layer 7 (Application)
    - TCP/IP, UDP, DHCP, DNS, etc.

### HaLVM web server example
- <a href="https://github.com/dmjio/Hello-HaLVM">Web Server example</a>

### Result
```
building path(s) /nix/store/<long-nix-hash>-hello-halvm
Parsing config from /nix/store/<long-nix-hash>-xenConfig
Assigned IP: (10,0,1,188)
C-[
$ curl 10.0.1.188
<!doctype html>
<html>
  <head></head>
  <body>HaLVM says Hello! You are request 0</body>
</html>%
```

### Future work
HaLVM 3
- <a href="http://uhsure.com/halvm3.html">HaLVM3 Roadmap</a>
- Backpack (ML Modules for Haskell), musl, Solo5
  - Swap out different hypervisor targets with ease

<!-- Best resource for future plans are Adam's blog post,
Musl is a small glibc replacement optimized for static linking -->

### Thanks!
HaLVM Lightning Talk

<a href="https://github.com/dmjio">@dmjio</a>
