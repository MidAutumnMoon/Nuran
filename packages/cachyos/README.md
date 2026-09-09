# Binary CachyOS Kernel

Stock CachyOS kernel packaged for NixOS.

Why? Because build kernel from source is very time consuming.
Any reason besides that? Hmm, not really :)

Porting binary kernel to other distros is surprisingly easy. The packaging is essentially moving files to right places that NixOS expects.

Limitations? Yeah, quite a lot:
- Can't build external modules with *this setup*. The stock CachyOS kernel contains headers, so it's technically possible. But my system is AMD with Btrfs, and I don't need them, so I removed the "dev" output. See the prototype repo for more details.
- Can't override the kernel config. Well, obviously.
- Dance around attrset shapes expected by nixpkgs. I'd simultaneously expect it to be broken in the near future and continue to work for a long time.

The raw plan and the prototype: <https://github.com/MidAutumnMoon/use-cachyos-bin-kernel-on-nixos-prototype>
