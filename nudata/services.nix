{ lib, ... }:

let

  service =
    content: lib.makeExtensible ( self: {
        local_addr =
          "[::1]:${toString self.port}";
        full_domain =
          "https://${self.domain}/";
      } // content );

in

{ nudata.services = {

  miniflux = service
    { port = 17861;
      domain = "rss.418.im";
    };

  libreddit = service
    { port = 17862;
      domain = "red.418.im";
    };

}; }
