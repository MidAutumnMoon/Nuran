lib:

let

    inherit ( builtins )
        isString
        ;

    inherit ( lib.strings )
        stringToCharacters
        toUpper
        concatStringsSep
        ;

    inherit ( lib.lists )
        head
        tail
        ;

in

{

    # capitalize :: string -> string
    #
    # Capitalize a string.
    #
    capitalize = string:
        assert isString string;
        assert string != "";
        let charList = stringToCharacters string; in
        let capFirstChar = toUpper ( head charList ); in
        concatStringsSep "" (
            [ capFirstChar ] ++ tail charList
        );

}
