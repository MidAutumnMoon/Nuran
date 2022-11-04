lib:

let

  inherit (builtins)
    isAttrs
    ;

in

{

  # flatMod :: attrset -> attrset
  #
  # Mixed module without the nested
  # "config" field.
  #
  # Don't write something like this
  #
  #   {
  #     imports =
  #       [ ... ];
  #     options =
  #       { ... };
  #     config =
  #       { deeply nested data structure };
  #   }
  #
  # instead write this
  #
  #   {
  #     imports = [ ... ];
  #     options = { ... };
  #     ..."unpacked" nested data structure
  #   }
  #
  # It reduces the nested madness by 1,
  # and it's huge.
  #
  flatMod =
    body:
      assert isAttrs body;
      { options =
          body.options or {};
        imports =
          body.imports or [];
        disabledModules =
          body.disabledModules or [];
        config =
          removeAttrs body [ "options" "imports" "disabledModules" ];
      };

}
