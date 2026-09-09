# Binary CachyOS Kernel

Stock CachyOS kernel packaged for NixOS.

Why? Because build kernel from source is very time consuming.
Any reason besides that? Hmm, not really :)

Porting binary kernel to other distros is surprisingly easy. The packaging is essentially moving files to right places that NixOS expects.

The package currently tracks x86_64-v3 `linux-cachyos` variant (LLVM+LTO). Other variants are trivial to package though.

Limitations? Yeah, quite a lot:

- Can't build external modules with _this setup_. The stock CachyOS kernel contains headers, so it's technically possible. But my system is AMD with Btrfs, and I don't need them, so I removed the "dev" output. See the prototype repo for more details.
- Can't override the kernel config. Well, obviously.
- Dance around attrset shapes expected by nixpkgs. I'd simultaneously expect it to be broken in the near future and continue to work for a long time.

The raw plan and the prototype: <https://github.com/MidAutumnMoon/use-cachyos-bin-kernel-on-nixos-prototype>

`config.json` and `release.json` are generated (see below), don't edit them manually.

## Updating

```console
nix run .#tsuki.__ci -- cachyos check
nix run .#tsuki.__ci -- cachyos update
nix run .#tsuki.__ci -- cachyos gen-config CONFIG [-o OUTPUT]
```

# Findings of what's missing in CachyOS stock kernel

Surprisingly, CachyOS config is almost identical to NixOS kernel. I'd say it's superior in some aspects.

1. The `request_key` patch. Trivial to work around. Or use smb without password.
2. 1k+ of exotic legacy drivers (because of the stupid perl script).
3. Few legacy options. NixOS should probably disable them.
