ppx\_module\_timer
==================

A ppx extension to record module startup times.

Modules using `ppx_module_timer` (included in `ppx_jane`) now have instrumentation to
record their startup time. If the environment variable `PPX_MODULE_TIMER` is set (to
anything), each module records its startup time, and before exiting the process prints out
all of the module times in the order they occurred.

If a file contains `[@@@ppx_module_timer.pay_overhead_to_time_individual_definitions]`,
the individual definitions will be timed (at the cost of some minor extra overhead.)
