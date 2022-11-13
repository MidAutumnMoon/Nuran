{

  sops.secrets."rclone_conf" =
    { owner = "teapot";
      sopsFile = ./rclone.yml;
    };

}
