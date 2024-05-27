{

  nuran.nginx.enable = true;

  services = {

    # psql 15 breakage workaround
    # GRANT ALL ON SCHEMA public TO miniflux;
    # ALTER DATABASE miniflux OWNER TO miniflux;
    miniflux.enable = true;

    libreddit.enable = true;

  };

}
