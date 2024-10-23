{
    fetchurl,
    writeText,
}:

let

    inherit ( builtins )
        concatStringsSep
        ;

    pic =
        url: hash: fetchurl { inherit url hash; };

in

writeText "something" ( concatStringsSep "\n" [

    ( pic
        "https://p.418.im/4ee3cc3c6939fdff.jpg"
        "sha256-70NDsdm75C34QYXD5rv3of8JVLJeBZw0n0PVODksXPg="
    )

    ( pic
        "https://p.418.im/6eb9ec34d6fbce88.jpg"
        "sha256-c5ijiijjIyVKbemmZ2q7sZ5v1t23n/ZFv83CS2m3Z7s="
    )

    ( pic
        "https://p.418.im/af6805468368003b.jpg"
        "sha256-k3BFLdYHq70iAJ/cZ8SlSj7Z1PZoy4LOxOvvnoXam30="
    )

    ( pic
        "https://p.418.im/6a028ca7b0ce32e8.jpg"
        "sha256-TBGdt91d/GqdU6UoZwXafFDgn7Q7Nyno6RCjh8QsbG0="
    )

] )
