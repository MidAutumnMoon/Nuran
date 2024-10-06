lib:

{

    # mySystems :: [ string ]
    #
    # Donations are welcomed!
    mySystems = [ "x86_64-linux" ];


    # eachSystem :: (string -> 'a) -> { string = 'a }
    eachSystem = lib.genAttrs lib.systems.flakeExposed;

}
