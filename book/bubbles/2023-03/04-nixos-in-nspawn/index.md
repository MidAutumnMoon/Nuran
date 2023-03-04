# Setup NixOS using systemd-nspawn

<!-- toc -->

- <https://hub.nspawn.org/images/> provides NixOS tarball
    - Has a sane default configuration.nix
        - Has `boot.loader.initScript.enable = true;` (otherwise nspawn won't be able to boot the system)
        - Has `boot.isContainer = true;`
            - Source at `nixos/modules/virtualisation/container-config.nix`
            - Disables kernel, documentation, firewall etc.
        - Uses `systemd-networkd`
        - But no `sshd`

- Use `machinectl pull-tar <hub url>` to fetch NixOS tarball
    - To give the new system a nickname `<machinectl cmd> nickname`
    - Delete leftover tarball with `machinectl clean`

- Configure the host side
    - Edit `/etc/systemd/nspawn/nickname.nspawn`
        - Set `Private = no` under `[Network]`(saves a lot of headache)
        - Set `Capability = all` under `[Exec]`(also a time-saver)
            - Optionally set `PrivateUsers = no`
    - Start this container when booting `systemctl enable systemd-nspawn@nickname`

- Start the container `machinectl start nickname`

- Configure the inside NixOS
    - To access the container `machinectl shell root@nickname`
    - Do a channel update
    - Edit `/etc/nixos/configuration.nix`
        - Set `services.openssh.enable = true;` so that it looks like being a normal system
            - Change the port to not conflict with the host's sshd
    - Do a `nixos-rebuild`

That should be everything.
