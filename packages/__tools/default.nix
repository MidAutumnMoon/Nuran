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
        shebangProgram = pkgs.ruby_teapot.with_preferred_gems;
    };

    binary-cache-builder = self.rubyMiner {
        path = ./binary-cache-builder.rb;
    };

    nix-update-driver = self.rubyMiner {
        path = ./nix-update-driver.rb;
        runtimeDeps = with pkgs; [ nix-update ];
    };

} )
