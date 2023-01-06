lib:

{

  # :hidden: mySystems
  #
  # What machines does MidAutumnMoon have?
  # Donations are welcomed!
  #
  mySystems = [
      "x86_64-linux"
    ];


  # forEachSystem :: (string -> whatever) -> attrset
  #
  # genAttrs on $allSystems.
  #
  forEachSystem =
    lib.genAttrs lib.systems.flakeExposed;

}
