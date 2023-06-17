{ pkgs, ... }:

{ boot = {

    kernelPackages = pkgs.linuxPackages_latest;

    kernelParams = [
        "init_on_alloc=1"
        "vsyscall=none"
    ];

    kernel.sysctl = {
        "kernel.dmesg_restrict" = 1;
        "kernel.unprivileged_bpf_disabled" = 1;
        "dev.tty.ldisc_autoload" = 0;
        "kernel.kexec_load_disabled" = 1;
        "vm.max_map_count" = 2147483642;
    };

}; }
