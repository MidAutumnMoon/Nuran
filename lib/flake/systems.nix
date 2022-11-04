lib:

rec {

  # :hidden: mySystems
  #
  # What machines does MidAutumnMoon have?
  # Donations are welcome!
  #
  mySystems =
    [
      "x86_64-linux"
    ];


  # :hidden: allSystems
  #
  # Currently set to what Hydra supports
  #
  allSystems =
    lib.systems.flakeExposed;


  # :hidden: forEachSystem :: (string -> whatever) -> attrset
  #
  # genAttrs on $allSystems.
  #
  forEachSystem =
    lib.genAttrs allSystems;

}
