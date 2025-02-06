with (builtins.getFlake (toString ../.)).lib; let pkgs = import <nixpkgs> {}; in


# libsToCompilerEnvvars ( with pkgs; [
#     libsodium
#     zeromq
# ] )

pkgs.mkShellNoCC rec {
    packages = with pkgs; [ nng pkg-config ];
    shellHook = libsToCompilerEnvvars packages;
}
