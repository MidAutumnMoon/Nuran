lib:

let

  inherit ( builtins )
    isPath
    fromTOML
    readFile
    ;

in

{

  # readVersionCargo :: path -> string
  #
  # Read "version" field from Cargo.toml
  #
  readVersionCargo =
    cargoTOML:
      assert isPath cargoTOML;
      ( fromTOML ( readFile cargoTOML ) ).package.version;

}
