with (builtins.getFlake (toString ../.)).lib; let pkgs = import <nixpkgs> {}; in

let

  pkgsBrew = brewNixpkgs <nixpkgs> {};

in

brewShells pkgsBrew rec {

  default = listOfPackages;

  listOfPackages = p: [ p.hello ];

  withHook = p: {
    packages = [ p.hello ];
    shellHook = ''
      echo "This should hello"
      hello
      '';
  };

  passthru = p: 123;

}
