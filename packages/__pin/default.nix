# The root overlay's view of the pins: fake packages, flat under each
# system, reassembled from pins.json by the driver.
{
    system,
}:

import ./driver.nix {
    inherit system;
    pins = builtins.fromJSON (builtins.readFile ./pins.json);
}
