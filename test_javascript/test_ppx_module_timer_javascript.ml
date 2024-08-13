open! Core

module Observer = struct
  type t = { take_records : unit -> unit }

  let token = "a28e3392-3057-4918-afc5-0b8fad870d59"

  let create () : t =
    let open Js_of_ocaml in
    let observer =
      PerformanceObserver.observe ~entry_types:[ "measure"; "mark" ] ~f:(fun _ _ -> ())
    in
    let take_records () =
      Array.iter
        (Js.to_array observer##takeRecords)
        ~f:(fun entry ->
          let name = Js.to_string entry##.name
          and entry_type = Js.to_string entry##.entryType in
          if not (String.is_substring name ~substring:token)
          then print_s [%message (name : string) (entry_type : string)])
    in
    { take_records }
  ;;

  let finish () =
    Ppx_module_timer_runtime.For_testing.Javascript_performance.mark_start token
  ;;
end

open Ppx_module_timer_runtime.For_testing.Javascript_performance

let%expect_test "Testing [mark_start] and [mark_end] in javascript and wasm" =
  let { Observer.take_records } = Observer.create () in
  mark_start __MODULE__;
  mark_end ();
  take_records ();
  [%expect
    {|
    ((name lib:Test_ppx_module_timer_javascript_start) (entry_type mark))
    ((name mod:Test_ppx_module_timer_javascript_start) (entry_type mark))
    ((name mod:Test_ppx_module_timer_javascript_end) (entry_type mark))
    ((name mod:Test_ppx_module_timer_javascript) (entry_type measure))
    |}];
  Observer.finish ();
  take_records ();
  [%expect
    {|
    ((name lib:Test_ppx_module_timer_javascript_end) (entry_type mark))
    ((name lib:Test_ppx_module_timer_javascript) (entry_type measure))
    |}]
;;

let%expect_test "module name without lib name" =
  let { Observer.take_records } = Observer.create () in
  mark_start "Foo";
  mark_end ();
  take_records ();
  [%expect
    {|
    ((name lib:Foo_start) (entry_type mark))
    ((name mod:Foo_start) (entry_type mark))
    ((name mod:Foo_end) (entry_type mark))
    ((name mod:Foo) (entry_type measure))
    |}];
  Observer.finish ();
  take_records ();
  [%expect
    {|
    ((name lib:Foo_end) (entry_type mark))
    ((name lib:Foo) (entry_type measure))
    |}]
;;

let%expect_test "module name with lib name" =
  let { Observer.take_records } = Observer.create () in
  mark_start "Foo__bar";
  mark_end ();
  take_records ();
  [%expect
    {|
    ((name lib:Foo_start) (entry_type mark))
    ((name mod:bar_start) (entry_type mark))
    ((name mod:bar_end) (entry_type mark))
    ((name mod:bar) (entry_type measure))
    |}];
  Observer.finish ();
  take_records ();
  [%expect
    {|
    ((name lib:Foo_end) (entry_type mark))
    ((name lib:Foo) (entry_type measure))
    |}]
;;

let%expect_test "multiple modules inside lib" =
  let { Observer.take_records } = Observer.create () in
  mark_start "Foo__a";
  mark_end ();
  mark_start "Foo__b";
  mark_end ();
  take_records ();
  [%expect
    {|
    ((name lib:Foo_start) (entry_type mark))
    ((name mod:a_start) (entry_type mark))
    ((name mod:a_end) (entry_type mark))
    ((name mod:a) (entry_type measure))
    ((name mod:b_start) (entry_type mark))
    ((name mod:b_end) (entry_type mark))
    ((name mod:b) (entry_type measure))
    |}];
  Observer.finish ();
  take_records ();
  [%expect
    {|
    ((name lib:Foo_end) (entry_type mark))
    ((name lib:Foo) (entry_type measure))
    |}]
;;
