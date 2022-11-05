{

  security.polkit.extraConfig =
    builtins.readFile ./policy.js;

}
