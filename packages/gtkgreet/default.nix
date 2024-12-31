{
    greetd,
}:

let

    inherit ( greetd ) gtkgreet;

in

gtkgreet.overrideAttrs ( oldAttrs: {

    patches = oldAttrs.patches or [] ++ [
        # gtkgreet doesn't have the ability to remember
        # last logined user, dirty workaround this is
        ./hardcode-teapot.patch

        # some annoying labels
        ./remove-label.patch
    ];

} )
