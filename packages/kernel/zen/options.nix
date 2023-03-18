{ lib }:

with lib.kernel;

let

  forceNo = lib.mkForce no;

  forceOptionNo = lib.mkForce ( option no );

in

{

  ZEN_INTERACTIVE = yes;

  MZEN2 = yes;
  PREEMPT_VOLUNTARY = yes;
  CC_OPTIMIZE_FOR_PERFORMANCE_O3 = yes;

  LRU_GEN = yes;
  LRU_GEN_ENABLED = yes;

  SCHED_BORE = yes;

}
