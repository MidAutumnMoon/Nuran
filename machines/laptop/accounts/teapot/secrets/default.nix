{

  sops.secrets."rclone_hetzner" =
    { owner = "teapot";
      sopsFile = ./rclone.yml;
    };

}
