with (builtins.getFlake (toString ../.)).lib; let pkgs = import <nixpkgs> {}; in

( brewNixpkgs <nixpkgs> {} )
|> ( it: it.appendOverlays [ ( final: prev: { x = 1; } ) ] )
|> ( it: it.appendSystems [ "x86_64-musl" ] )
|> ( it: it ( pkgs: pkgs.x ) )
