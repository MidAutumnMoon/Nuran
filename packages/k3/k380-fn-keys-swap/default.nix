{
    lib,
    sources,
    stdenv,
    runtimeShell,
}:

stdenv.mkDerivation ( drvSelf: {

    pname = "k380-fn-keys-swap";

    version = "unstable";

    inherit ( sources.${drvSelf.pname} )
        src;


    passAsFile = [
        "k380AutoSwap"
        "udevRule"
    ];

    k380AutoSwap = ''
        #!${runtimeShell}
        DEVICE="$(ls -l /sys/class/hidraw | grep 046D:B342 | grep -o 'hidraw[0-9]*$')"

        if test -n "$DEVICE" && (test -z "$1" || test "/dev/$DEVICE" = "$1"); then
          echo "Found K380 keyboard at $DEVICE."
          exec '${placeholder "out"}/bin/${drvSelf.pname}' -d "/dev/$DEVICE" -f 'on'
        fi
    '';

    udevRule = ''
        ACTION=="add", KERNEL=="hidraw[0-9]*", RUN+="${placeholder "out"}/lib/k380AutoSwap /dev/%k"
    '';


    buildPhase = ''
        $CC k380_conf.c -o "${drvSelf.pname}"
    '';

    installPhase = ''
        mkdir -p $out/bin
        install -Dm755 "${drvSelf.pname}" "$out/bin"
        install -Dm755 "$k380AutoSwapPath" "$out/lib/k380AutoSwap"

        mkdir -p "$out/lib/udev/rules.d"
        install -Dm644 "$udevRulePath" "$out/lib/udev/rules.d/60-${drvSelf.pname}.rules"
    '';


    meta = {
        homepage = "https://github.com/jergusg/k380-function-keys-conf/";
        description = "Make function keys default on Logitech k380 bluetooth keyboard.";
        license = lib.licenses.gpl3;
        mainProgram = drvSelf.pname;
    };

} )
