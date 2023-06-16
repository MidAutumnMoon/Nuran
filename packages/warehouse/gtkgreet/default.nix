{
    greetd,
}:

greetd.gtkgreet.overrideAttrs ( oldAttrs: {


    patches = oldAttrs.patches or [] ++ [
        ./hardcode-teapot.patch
        ./remove-label.patch
    ];

} )
