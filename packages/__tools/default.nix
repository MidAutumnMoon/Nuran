{
    lib,
    pkgs,
    newScope,
}:

lib.makeScope newScope ( self: let

    callPackage = self.newScope {};

in {

    scriptMaker = ./script-maker.nix;

    rubyMiner = callPackage self.scriptMaker {
        shebangProgram = pkgs.ruby_teapot.brewed;
    };

    binary-cache-builder = self.rubyMiner {
        path = ./binary-cache-builder.rb;
    };

    nvfetcher-driver = self.rubyMiner {
        path = ./nvfetcher-driver.rb;
        runtimeDeps = with pkgs; [ which nvfetcher ];
    };

    goaway-vendorhash = self.rubyMiner {
        path = ./goaway-vendorhash.rb;
    };

} )
