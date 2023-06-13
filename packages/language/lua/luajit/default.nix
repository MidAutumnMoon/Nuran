{
  self,
  luajit,

  callPackage,

  deterministicStringIds ? true
}:


luajit.override {

    packageOverrides =
        callPackage ../packages { lua = self; };

    inherit deterministicStringIds;

}
