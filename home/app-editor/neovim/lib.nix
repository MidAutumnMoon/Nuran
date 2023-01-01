#
# Leave it here for a future reference.
#

lib: allPlugins:

let

  inherit (builtins)
    all
    isList
    length elemAt
    ;

in

rec {

  # pluginList :: [ [ ] ] -> [ attrset ]
  #
  # Transform a list of $record to home-manager's
  # neovim plugin config.
  #
  # $record is a list like:
  #
  #   [ name config type optional ] :: [ string path string bool ]
  #
  # and only the name field is required.
  #
  pluginList =
    recordList:
      assert isList recordList && length recordList >= 1;
      assert all isList recordList;
      map _toConfig recordList;


  # _toConfig :: [ ] -> attrset
  #
  _toConfig =
    record:
         (_toConfig_1 record)
      // ( if length record >= 2 then _toConfig_2 record else { } )
      // ( if length record >= 3 then _toConfig_3 record else { } )
      // ( if length record >= 4 then _toConfig_4 record else { } )
      ;

  _toConfig_1 =
    record:
      { plugin = allPlugins.${guessPluginName (elemAt record 0)}; };

  _toConfig_2 =
    record:
      { config = builtins.readFile (elemAt record 1); };

  _toConfig_3 =
    record:
      { type = elemAt record 2; };

  _toConfig_4 =
    record:
      { optional = elemAt record 3; };



  # guessPluginName :: string ->  string
  #
  # What's wrong with Vim plugins in nixpkgs?
  #
  # First try to find $name in vimPlugins, if that attr does not exits,
  # then try "vim-$name", then try "$name-vim" etc.,
  # There must be one correct name, right??
  #
  guessPluginName =
    name:
      let
        result = _guessNames name;
      in
        if result == [ ]
        then abort ''Plugin "${name}" not found?''
        else
          # If multiple plugins were found for the $name,
          # it should probably be a alias.
          lib.head result;


  # _guessNames :: attrset -> string -> [ string ]
  #
  _guessNames =
    name:
      builtins.filter (n: builtins.hasAttr n allPlugins)
        [
          "${name}"
          "vim-${name}" "${name}-vim"
          "nvim-${name}" "${name}-nvim"
        ];

}
