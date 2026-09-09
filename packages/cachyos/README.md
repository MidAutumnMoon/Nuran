# Binary CachyOS Kernel

Stock CachyOS kernel packaged for NixOS.

Why? Because build kernel from source is very time consuming.
Any reason besides that? Hmm, not really :)

Porting binary kernel to other distros is surprisingly easy. The packaging is essentially moving files to right places that NixOS expects.

Limitations? Yeah, quite a lot:
- Can't *easily* build external modules with it. However, this sounds like a big drawback but actually no. My system is AMD based with Btrfs, so non external modules are required. CachyOS also builds binary modules for nvidia and zfs. With enough fiddling, they can probably work, but I haven't exercised them yet. See the prototype repo for more details.
- Can't override the kernel config. Well, obviously.

The raw plan and the prototype: <https://github.com/MidAutumnMoon/use-cachyos-bin-kernel-on-nixos-prototype>
