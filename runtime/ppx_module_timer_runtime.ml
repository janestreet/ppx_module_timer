open! Base

external __MODULE__ : string = "%loc_MODULE"

let am_recording_environment_variable = "PPX_MODULE_TIMER"

let get_am_recording_environment_variable () =
  (* avoid Caml.Sys.getenv_opt to preserve 4.04.x compatibility *)
  match Caml.Sys.getenv am_recording_environment_variable with
  | value -> Some value
  | exception _ -> None
;;

let am_recording = Option.is_some (get_am_recording_environment_variable ())

module Startup_time = struct
  type t =
    { module_name : string
    ; startup_time_in_nanoseconds : Int63.t
    }
  [@@deriving sexp_of]
end

let startup_times_in_reverse_chronological_order = ref []
let currently_running_module_name = ref ""
let currently_running_module_start = ref Int63.zero

let reset_currently_running_module () =
  currently_running_module_name := "";
  currently_running_module_start := Int63.zero
;;

let record_start module_name =
  if am_recording
  then (
    assert (String.is_empty !currently_running_module_name);
    currently_running_module_name := module_name;
    (* call [Time_now] as late as possible before running the module body *)
    currently_running_module_start := Time_now.nanoseconds_since_unix_epoch ())
;;

let record_until module_name =
  if am_recording
  then (
    (* compute [Time_now] as soon as possible after running the module body *)
    let until = Time_now.nanoseconds_since_unix_epoch () in
    let start = !currently_running_module_start in
    let startup_time_in_nanoseconds = Int63.( - ) until start in
    assert (String.equal !currently_running_module_name module_name);
    let startup_time : Startup_time.t = { module_name; startup_time_in_nanoseconds } in
    startup_times_in_reverse_chronological_order :=
      startup_time :: !startup_times_in_reverse_chronological_order;
    reset_currently_running_module ())
;;

let string_of_span_in_ns nanos = Int63.to_string nanos ^ "ns"

let char_is_digit_or_underscore = function
  | '0' .. '9'
  | '_' -> true
  | _ -> false
;;

let span_in_ns_of_string string =
  match String.chop_suffix string ~suffix:"ns" with
  | Some prefix
    when String.for_all prefix ~f:char_is_digit_or_underscore ->
    Some (Int63.of_string prefix)
  | _ -> None
;;

let print_with_left_column_right_justified alist =
  let left_column_width =
    List.fold alist ~init:0 ~f:(fun width (left, _) -> Int.max width (String.length left))
  in
  List.iter alist ~f:(fun (left, right) ->
    Stdio.printf "%*s %s\n" left_column_width left right)
;;

let default_print_recorded_startup_times startup_times =
  let startup_times =
    match
      get_am_recording_environment_variable () |> Option.bind ~f:span_in_ns_of_string
    with
    | None -> startup_times
    | Some override ->
      Stdio.print_endline "ppx_module_timer: overriding time measurements for testing";
      List.mapi startup_times ~f:(fun index (startup_time : Startup_time.t) ->
        let startup_time_in_nanoseconds =
          Int63.( * ) override (Int63.of_int (index + 1))
        in
        { startup_time with startup_time_in_nanoseconds })
  in
  List.map
    startup_times
    ~f:(fun ({ module_name; startup_time_in_nanoseconds } : Startup_time.t) ->
      string_of_span_in_ns startup_time_in_nanoseconds, module_name)
  |> print_with_left_column_right_justified
;;

let print_recorded_startup_times = ref default_print_recorded_startup_times

let () =
  Caml.at_exit (fun () ->
    !print_recorded_startup_times
      (List.rev !startup_times_in_reverse_chronological_order))
;;
