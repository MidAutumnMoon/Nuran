{ pkgs, ... }:

{

    boot.kernelPackages = pkgs.linuxPackages_latest;

    boot.kernelParams = [
        "init_on_alloc=1"
        "vsyscall=none"
    ];

    boot.kernel.sysctl = {
        "kernel.dmesg_restrict" = 1;
        "kernel.unprivileged_bpf_disabled" = 1;
        "dev.tty.ldisc_autoload" = 0;
        "kernel.kexec_load_disabled" = 1;
    };

}

