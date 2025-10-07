open Ppxlib

(** This function attempts to insert the input structure item _after_ [ppx_module_timer]
    so that it can be evaluated by [ppx_module_timer]. It's naive and a bit hacky, so we
    recommend that you only use it if your ppx evaluation takes a while.

    It's useful if your ppx hoists a structure item to the top of the file, and the
    hoister does a significant amount of processing when it's constructed. *)
val attempt_to_put_structure_item_after_the_ppx_module_timer_start
  :  structure_item:structure_item
  -> structure
  -> structure
