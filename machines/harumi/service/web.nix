{ config, ... }:

{

  nuran.nginx.enable = true;

  services.miniflux.enable = true;

  nuran.services.erohon =
    { enable = true;
      repoPath =
        config.fileSystems."/data/erohon".mountPoint;
    };

  services.shiori.enable = true;

  services.libreddit.enable = true;

  nuran.services.hentai-home =
    { enable = true;
      port = 33679;
      dataDir =
        config.fileSystems."/data/hentai-home".mountPoint;
    };

}
