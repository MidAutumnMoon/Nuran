{ lib, config, ... }:

{

    users.mutableUsers = lib.mkForce false;

    users.users."root" = {
        hashedPassword =
            "$6$ilpMFCeYJ6Fb9oZ2$x/T2pFWDs6ruZufnTSK62hUknVYG0LM9jcugHYjCWOutuQQ0FNbOFjPq6jXQg6YPiqhiczKg3S15IUOUhD.f7/";
        openssh.authorizedKeys.keys = [
            config.nudata.pubkeys.self
        ];
    };

}
