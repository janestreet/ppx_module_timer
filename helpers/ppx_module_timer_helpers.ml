open Ppxlib

let attempt_to_put_structure_item_after_the_ppx_module_timer_start
  ~structure_item
  (entire_file : structure)
  =
  match entire_file with
  | ([%stri
       let () = Ppx_module_timer_runtime.record_start Ppx_module_timer_runtime.__MODULE__]
     as first)
    :: remaining ->
    first :: structure_item :: remaining
    (* Conservatively match on ppx_module_timer_runtime being the first item. If it is,
       we'll place our hoister after it so that we can include the hoister in the module
       timer *)
  | _ ->
    (* Default to putting the hoisted module at the very front of the structure *)
    structure_item :: entire_file
;;
