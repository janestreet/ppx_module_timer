open! Core
open! Async
open Expect_test_helpers_async

let time_override = "300ns"
let list_override = "FAKE_MODULES"

let executables =
  [ "../examples/bin/hello_world_without_dependencies.exe", time_override
  ; "../examples/bin/hello_world_with_bin_dependencies.exe", time_override
  ; "../examples/bin/hello_world_with_lib_dependencies.exe", time_override
  ; "../examples/bin/hello_world_with_core_dependencies.exe", list_override
  ; "../examples/lib/inline_tests_runner -list-partitions", time_override
  ; ( "../examples/lib/inline_benchmarks_runner -matching nonexistent \
       -run-without-cross-library-inlining -suppress-warnings"
    , list_override )
  ]
;;

let run ?extend_env string =
  match String.split string ~on:' ' with
  | [] -> assert false
  | prog :: args -> run prog args ?extend_env
;;

let%expect_test "without output" =
  let%bind () =
    Deferred.List.iter ~how:`Sequential executables ~f:(fun (executable, _) ->
      printf "\n$ %s\n\n" executable;
      run executable)
  in
  [%expect
    {|
    $ ../examples/bin/hello_world_without_dependencies.exe

    Hello, world.

    $ ../examples/bin/hello_world_with_bin_dependencies.exe

    Hello, world.

    $ ../examples/bin/hello_world_with_lib_dependencies.exe

    Hello, world.

    $ ../examples/bin/hello_world_with_core_dependencies.exe

    Hello, world.

    $ ../examples/lib/inline_tests_runner -list-partitions

    ppx_module_timer_example_lib

    $ ../examples/lib/inline_benchmarks_runner -matching nonexistent -run-without-cross-library-inlining -suppress-warnings
    |}];
  return ()
;;

let%expect_test "with deterministic output" =
  let%bind () =
    Deferred.List.iter ~how:`Sequential executables ~f:(fun (executable, override) ->
      let extend_env =
        [ Ppx_module_timer_runtime.am_recording_environment_variable, override ]
      in
      printf "\n$ %s\n\n" executable;
      run executable ~extend_env)
  in
  [%expect
    {|
    $ ../examples/bin/hello_world_without_dependencies.exe

    Hello, world.
    ppx_module_timer: overriding time measurements for testing
    300ns Bin_prefix_hello_world_without_dependencies_and_hello_world_with_bin_dependencies_etc__Hello_world_without_dependencies

    $ ../examples/bin/hello_world_with_bin_dependencies.exe

    Hello, world.
    ppx_module_timer: overriding time measurements for testing
    300ns Bin_prefix_hello_world_without_dependencies_and_hello_world_with_bin_dependencies_etc__Bin_dependency_constant
    600ns Bin_prefix_hello_world_without_dependencies_and_hello_world_with_bin_dependencies_etc__Bin_dependency_io
    900ns Bin_prefix_hello_world_without_dependencies_and_hello_world_with_bin_dependencies_etc__Hello_world_with_bin_dependencies

    $ ../examples/bin/hello_world_with_lib_dependencies.exe

    Hello, world.
    ppx_module_timer: overriding time measurements for testing
     300ns Ppx_module_timer_example_lib__Lib_dependency_constant; GC: 1 minor collections
     600ns Ppx_module_timer_example_lib__Lib_dependency_io
     900ns Ppx_module_timer_example_lib__Lib_dependency_command
         300ns File "lib_dependency_command.ml", line 1, characters 0-0
         600ns File "lib_dependency_command.ml", line 1, characters 0-0
         900ns File "lib_dependency_command.ml", line 1, characters 0-0
        1200ns File "lib_dependency_command.ml", line 2, characters 2-53
        1500ns File "lib_dependency_command.ml", line 3, characters 2-55
        1800ns File "lib_dependency_command.ml", line 6, characters 0-11
        2100ns File "lib_dependency_command.ml", line 8, characters 0-50
        2400ns File "lib_dependency_command.ml", line 10, characters 0-65
        2700ns File "lib_dependency_command.ml", line 10, characters 65-65
        3000ns File "lib_dependency_command.ml", line 10, characters 65-65
        3300ns File "lib_dependency_command.ml", line 10, characters 65-65
    1200ns Ppx_module_timer_example_lib
    1500ns Bin_prefix_hello_world_without_dependencies_and_hello_world_with_bin_dependencies_etc__Hello_world_with_lib_dependencies

    $ ../examples/bin/hello_world_with_core_dependencies.exe

    Hello, world.
    ppx_module_timer: overriding time measurements for testing
     0.900us Fake__Dependency_1
     1.800us Fake__Dependency_2; GC: 1 minor collections
     2.700us Fake__Dependency_3
     3.600us Fake__Dependency_4; GC: 1 minor collections, 1 major collections
        0.900us Line 1
        1.800us Line 2; GC: 1 minor collections
        2.700us Line 3
        3.600us Line 4; GC: 1 minor collections, 1 major collections
     4.500us Fake__Dependency_5
     5.400us Fake__Dependency_6; GC: 1 minor collections
     6.300us Fake__Dependency_7
     7.200us Fake__Dependency_8; GC: 1 minor collections, 1 major collections, 1 compactions
        0.900us Line 1
        1.800us Line 2; GC: 1 minor collections
        2.700us Line 3
        3.600us Line 4; GC: 1 minor collections, 1 major collections
        4.500us Line 5
        5.400us Line 6; GC: 1 minor collections
        6.300us Line 7
        7.200us Line 8; GC: 1 minor collections, 1 major collections, 1 compactions
     8.100us Fake__Dependency_9
     9.000us Fake__Dependency_10; GC: 1 minor collections
     9.900us Fake__Dependency_11
    10.800us Fake__Dependency_12; GC: 1 minor collections, 1 major collections
         0.900us Line 1
         1.800us Line 2; GC: 1 minor collections
         2.700us Line 3
         3.600us Line 4; GC: 1 minor collections, 1 major collections
         4.500us Line 5
         5.400us Line 6; GC: 1 minor collections
         6.300us Line 7
         7.200us Line 8; GC: 1 minor collections, 1 major collections, 1 compactions
         8.100us Line 9
         9.000us Line 10; GC: 1 minor collections
         9.900us Line 11
        10.800us Line 12; GC: 1 minor collections, 1 major collections

    $ ../examples/lib/inline_tests_runner -list-partitions

    ppx_module_timer_example_lib
    ppx_module_timer: overriding time measurements for testing
     300ns Ppx_module_timer_example_lib_via_jbuild_flag
         300ns File "ppx_module_timer_example_lib_via_jbuild_flag.ml", line 3, characters 0-11
         600ns File "ppx_module_timer_example_lib_via_jbuild_flag.ml", line 4, characters 0-11
         900ns File "ppx_module_timer_example_lib_via_jbuild_flag.ml", line 5, characters 0-11
        1200ns File "ppx_module_timer_example_lib_via_jbuild_flag.ml", line 6, characters 0-11
        1500ns File "ppx_module_timer_example_lib_via_jbuild_flag.ml", line 7, characters 0-11
        1800ns File "ppx_module_timer_example_lib_via_jbuild_flag.ml", line 8, characters 0-11
        2100ns File "ppx_module_timer_example_lib_via_jbuild_flag.ml", line 9, characters 0-11
        2400ns File "ppx_module_timer_example_lib_via_jbuild_flag.ml", line 10, characters 0-11
        2700ns File "ppx_module_timer_example_lib_via_jbuild_flag.ml", line 11, characters 0-11
        3000ns File "ppx_module_timer_example_lib_via_jbuild_flag.ml", line 14, characters 2-13
        3300ns File "ppx_module_timer_example_lib_via_jbuild_flag.ml", line 15, characters 2-13
        3600ns File "ppx_module_timer_example_lib_via_jbuild_flag.ml", line 16, characters 2-13
        3900ns File "ppx_module_timer_example_lib_via_jbuild_flag.ml", line 20, characters 2-13
        4200ns File "ppx_module_timer_example_lib_via_jbuild_flag.ml", line 21, characters 2-13
        4500ns File "ppx_module_timer_example_lib_via_jbuild_flag.ml", line 22, characters 2-13
        4800ns File "ppx_module_timer_example_lib_via_jbuild_flag.ml", line 28, characters 2-13
        5100ns File "ppx_module_timer_example_lib_via_jbuild_flag.ml", line 29, characters 2-13
        5400ns File "ppx_module_timer_example_lib_via_jbuild_flag.ml", line 30, characters 2-13
        5700ns File "ppx_module_timer_example_lib_via_jbuild_flag.ml", line 33, characters 0-23
     600ns Ppx_module_timer_example_lib__Lib_dependency_constant; GC: 1 minor collections
     900ns Ppx_module_timer_example_lib__Lib_dependency_io
    1200ns Ppx_module_timer_example_lib__Lib_dependency_command
         300ns File "lib_dependency_command.ml", line 1, characters 0-0
         600ns File "lib_dependency_command.ml", line 1, characters 0-0
         900ns File "lib_dependency_command.ml", line 1, characters 0-0
        1200ns File "lib_dependency_command.ml", line 2, characters 2-53
        1500ns File "lib_dependency_command.ml", line 3, characters 2-55
        1800ns File "lib_dependency_command.ml", line 6, characters 0-11
        2100ns File "lib_dependency_command.ml", line 8, characters 0-50
        2400ns File "lib_dependency_command.ml", line 10, characters 0-65
        2700ns File "lib_dependency_command.ml", line 10, characters 65-65
        3000ns File "lib_dependency_command.ml", line 10, characters 65-65
        3300ns File "lib_dependency_command.ml", line 10, characters 65-65
    1500ns Ppx_module_timer_example_lib
    1800ns Ppx_module_timer_example_lib__Test_regression_pay_overhead_to_time_individual_definitions
         300ns File "test_regression_pay_overhead_to_time_individual_definitions.ml", line 1, characters 0-65
         600ns File "test_regression_pay_overhead_to_time_individual_definitions.ml", line 3, characters 0-0
         900ns File "test_regression_pay_overhead_to_time_individual_definitions.ml", line 3, characters 0-0
        1200ns File "test_regression_pay_overhead_to_time_individual_definitions.ml", line 3, characters 0-0
        1500ns File "test_regression_pay_overhead_to_time_individual_definitions.ml", line 3, characters 0-11
        1800ns File "test_regression_pay_overhead_to_time_individual_definitions.ml", line 4, characters 0-11
        2100ns File "test_regression_pay_overhead_to_time_individual_definitions.ml", line 5, characters 0-68
        2400ns File "test_regression_pay_overhead_to_time_individual_definitions.ml", line 5, characters 68-68
        2700ns File "test_regression_pay_overhead_to_time_individual_definitions.ml", line 5, characters 68-68
        3000ns File "test_regression_pay_overhead_to_time_individual_definitions.ml", line 5, characters 68-68

    $ ../examples/lib/inline_benchmarks_runner -matching nonexistent -run-without-cross-library-inlining -suppress-warnings

    ppx_module_timer: overriding time measurements for testing
     0.900us Fake__Dependency_1
     1.800us Fake__Dependency_2; GC: 1 minor collections
     2.700us Fake__Dependency_3
     3.600us Fake__Dependency_4; GC: 1 minor collections, 1 major collections
        0.900us Line 1
        1.800us Line 2; GC: 1 minor collections
        2.700us Line 3
        3.600us Line 4; GC: 1 minor collections, 1 major collections
     4.500us Fake__Dependency_5
     5.400us Fake__Dependency_6; GC: 1 minor collections
     6.300us Fake__Dependency_7
     7.200us Fake__Dependency_8; GC: 1 minor collections, 1 major collections, 1 compactions
        0.900us Line 1
        1.800us Line 2; GC: 1 minor collections
        2.700us Line 3
        3.600us Line 4; GC: 1 minor collections, 1 major collections
        4.500us Line 5
        5.400us Line 6; GC: 1 minor collections
        6.300us Line 7
        7.200us Line 8; GC: 1 minor collections, 1 major collections, 1 compactions
     8.100us Fake__Dependency_9
     9.000us Fake__Dependency_10; GC: 1 minor collections
     9.900us Fake__Dependency_11
    10.800us Fake__Dependency_12; GC: 1 minor collections, 1 major collections
         0.900us Line 1
         1.800us Line 2; GC: 1 minor collections
         2.700us Line 3
         3.600us Line 4; GC: 1 minor collections, 1 major collections
         4.500us Line 5
         5.400us Line 6; GC: 1 minor collections
         6.300us Line 7
         7.200us Line 8; GC: 1 minor collections, 1 major collections, 1 compactions
         8.100us Line 9
         9.000us Line 10; GC: 1 minor collections
         9.900us Line 11
        10.800us Line 12; GC: 1 minor collections, 1 major collections
    |}];
  return ()
;;
