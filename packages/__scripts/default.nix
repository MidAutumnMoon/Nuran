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
        shebangProgram = pkgs.ruby_3_3;
    };

    binary-cache-builder = self.rubyMiner {
        path = ./binary-cache-builder.rb;
    };

} )
