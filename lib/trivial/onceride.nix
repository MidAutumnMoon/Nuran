lib:

let

  inherit (lib)
    isAttrs
    isFunction
    isDerivation
    ;

in

{

  # onceride ::
  #  what override accepts -> what overrideAttrs accepts -> new derivation
  #
  # Mess around another mess.
  #
  onceride =
    drv: overrideEssence: overrideAttrsEssence:
      assert isDerivation drv;
      assert isAttrs overrideEssence
             || isFunction overrideEssence;
      assert isFunction overrideAttrsEssence;
      ( drv.override overrideEssence ).overrideAttrs overrideAttrsEssence;

  # onceride' ::
  #  what override accepts -> what overrideDerivation accepts -> new derivation
  #
  # Sometimes overrideAttrs is simply not enough.
  #
  oncerideDrv =
    drv: overrideEssence: overrideDrvEssence:
      assert isDerivation drv;
      assert isAttrs overrideEssence
             || isFunction overrideEssence;
      assert isFunction overrideDrvEssence;
      ( drv.override overrideEssence ).overrideDerivation overrideDrvEssence;

}
