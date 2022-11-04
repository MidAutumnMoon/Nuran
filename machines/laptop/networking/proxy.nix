{

  networking.proxy =
    { default =
        "http://127.0.0.1:1082";
      noProxy =
        "127.0.0.1,localhost";
    };

  networking.firewall.extraCommands = ''
      iptables -A nixos-fw -p tcp \
        --src 192.168.50.0/24,192.168.122.1/24 \
        --match multiport \
          --dports 1081,1082,8080:8090 \
        --jump nixos-fw-accept
    '';

}
