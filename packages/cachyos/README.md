# Binary CachyOS Kernel

Stock CachyOS kernel packaged for NixOS.

Why? Because build kernel from source is very time consuming.
Any reason besides that? Hmm, not really :)

Porting binary kernel to other distros is surprisingly easy. The packaging is essentially moving files to right places that NixOS expects.

The tracked package is `linux-cachyos`, CachyOS's LLVM ThinLTO kernel for `x86_64_v3`.

## Updating

The repository CI driver owns both release metadata and config generation:

```console
nix run .#tsuki.__ci -- cachyos check
nix run .#tsuki.__ci -- cachyos update
nix run .#tsuki.__ci -- cachyos gen-config CONFIG [-o OUTPUT]
```

`check` exits with status 3 when an update is available. `update --force`
redownloads and regenerates an unchanged pin.

Limitations? Yeah, quite a lot:
- Can't build external modules with *this setup*. The stock CachyOS kernel contains headers, so it's technically possible. But my system is AMD with Btrfs, and I don't need them, so I removed the "dev" output. See the prototype repo for more details.
- Can't override the kernel config. Well, obviously.
- Dance around attrset shapes expected by nixpkgs. I'd simultaneously expect it to be broken in the near future and continue to work for a long time.

The raw plan and the prototype: <https://github.com/MidAutumnMoon/use-cachyos-bin-kernel-on-nixos-prototype>
