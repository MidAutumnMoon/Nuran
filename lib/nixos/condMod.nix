lib:

let

  inherit (builtins)
    isAttrs isBool
    ;

  _condMod =
    cond: body:
      body // { config = lib.mkIf cond body.config; };

in

{

  # condMod :: bool -> attrset -> attrset
  #
  # A wrapper of the "config = mkIf" pattern
  # to help reducing the nested attrsets.
  #
  # The $cond is a boolean which will be
  # the first argument of mkIf,
  # and the $body is an attrset that may come
  # with different shapes.
  #
  #
  # 1)
  # The basic form of $body may just be
  # a normal module, e.g.
  #
  #   condMod cond {
  #     services.hello.niceDay = true;
  #   }
  #
  # and vice versa.
  #
  #
  # 2)
  # Since condMod uses "flatMod" under the
  # hood, the $body may contain "imports"
  # and/or "options" fields.
  #
  # Something like this is ok.
  #
  #   condMod cond {
  #     options.rocks =
  #       rick = mkOption ...;
  #     programs.vlc.volume = 100;
  #   }
  #
  # The confusing part is that "options"
  # and "imports" aren't effected by
  # the $cond, but still looks like to
  # be guarded by it.
  #
  condMod =
    cond: body:
      # $cond shouldn't be type checked
      assert isAttrs body;
      _condMod cond (lib.nuran.nixos.flatMod body);

}
