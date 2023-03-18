{ iosevka }:

iosevka.override {

  set = "teapot";

  privateBuildPlan =
    builtins.readFile ./plan.toml;

}
