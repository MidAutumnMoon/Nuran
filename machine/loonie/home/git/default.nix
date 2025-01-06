{ nixosConfig, config, pkgs, ... }:

let

    inherit ( pkgs )
        writeText
    ;

    allowedSigners = writeText "git-allowed-signers" ''
        me@418.im ${nixosConfig.lore.pubkeys.teapot}
    '';

in {

    # imports = [ ./delta.nix ];

    home.packages = with pkgs; [ git ];

    sops.secrets."git_cred".sopsFile = ./git_cred.sops.yml;

    xdg.configFile."git/config".text = ''
        [user]
            email = "me@418.im"
            name = "MidAutumnMoon"

        [merge]
            conflictstyle = "diff3"

        [diff]
            mnemonicPrefix = true

        [pull]
            rebase = "merges"

        [status]
            showUntrackedFiles = "all"

        [init]
            defaultBranch = "master"

        [core]
            quotePath = false

        [credential]
            helper = "store --file=${config.sops.secrets."git_cred".path}"

        [gc]
            auto = 0


        # Alias

        [alias]
            kill-reflog = "reflog expire --all --expire=now --expire-unreachable=now"


        # Signing

        [user]
            signingKey = "${config.sops.secrets."privkey_teapot".path}"

        [gpg]
            format = "ssh"

        [gpg "ssh"]
            allowedSignersFile = "${allowedSigners}"

        [commit]
            gpgSign = true

        [tag]
            gpgSign = true

    '';

}

# vim: nowrap:
