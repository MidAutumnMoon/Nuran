{ lib, ... }:

let

    service = content: lib.makeExtensible ( self: {
        local_addr = "[::1]:${toString self.port}";
        full_domain = "https://${self.domain}/";
    } // content );

in

{ nudata.services = {

    miniflux = service {
        port = 17861;
        domain = "rss.418.im";
    };

    libreddit = service {
        port = 17862;
        domain = "red.418.im";
    };

    dns = rec {
        listen_addr = "127.0.54.53";
        listen_addr6 = "::1";
        listen = [
            "${listen_addr}:53"
            "[${listen_addr6}]:53"
        ];
    };

}; }
