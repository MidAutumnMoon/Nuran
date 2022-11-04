{ lib, ... }:

#
# PR #159186 introduced several logrotate service changes, and it
# enables logrotate by default. So we kill it.
#

{

  services.logrotate.enable = lib.mkForce false;

}
