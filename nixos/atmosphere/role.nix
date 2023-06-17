{ lib, config,... }:

let

    inherit ( lib )
        flip
        attrNames
        concatMapAttrs
        mkOption
        types
        ;

    roles = {
        "personal" = {};
        "server" = {};
        "container" = {};
    };

    # Given a role named "rolename",
    # generate two options
    #
    # "rolename" = bool: if "role.type" is set to this name
    # "ifRolname" =  function: mkIf "rolename" ...
    #
    generatedHelpers = flip concatMapAttrs roles ( name: _: {
        ${name} = mkOption {
            type = types.bool;
            default =
                config.role.type == name;
            readOnly = true;
        };
        "if${lib.capitalize name}" = mkOption {
            type = types.functionTo types.anything;
            default =
                lib.mkIf config.role.${name};
            readOnly = true;
        };
    } );

in

lib.flatMod {

    options.role = {
        type = mkOption {
            type = types.enum ( attrNames roles );
            description = ''
                Define the role of a machine;
            '';
        };
    } // generatedHelpers;

}
