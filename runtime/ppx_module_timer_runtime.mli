open! Base

(** If true, ppx_module_timer records module startup times and reports them on stdout at
    process exit. Controlled by [am_recording_environment_variable]. *)
val am_recording : bool

(** If this environment variable is set (to anything) when this module starts up,
    [am_recording] is set to true.

    Equal to "PPX_MODULE_TIMER". *)
val am_recording_environment_variable : string

module Startup_time : sig
  type t =
    { module_name : string
    ; startup_time_in_nanoseconds : Int63.t
    }
  [@@deriving sexp_of]
end

(** If [am_recording], called at process exit. The list is given in chronological order.

    The default callback prints each module name and startup time in the order given. To
    provide deterministic behavior in tests, if [am_recording_environment_variable] has
    the format of a time span, each recorded startup time is printed as a successive
    increment of that value. *)
val print_recorded_startup_times : (Startup_time.t list -> unit) ref


(**/**)

(** {2 For Rewritten Code}

    These definitions are not meant to be called manually. *)

(** If [am_recording], records when the specified module begins its startup effects.
    Raises if a previous module started and has not finished. *)
val record_start : string -> unit

(** If [am_recording], records when the specified module finishes its startup effects.
    Raises if there is no corresponding start time. *)
val record_until : string -> unit

(** Duplicate of [Pervasives.__MODULE__]. *)
external __MODULE__ : string = "%loc_MODULE"