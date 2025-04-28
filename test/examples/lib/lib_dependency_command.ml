module Import = struct
  let print_endline = Lib_dependency_io.print_endline
  let hello_world = Lib_dependency_constant.hello_world
end

open Import

let run_hello_world () = print_endline hello_world

[@@@ppx_module_timer.pay_overhead_to_time_individual_definitions]
