#include <caml/mlvalues.h>
#include <caml/memory.h>
#include <caml/fail.h>

/* These stubs are only implemented in javascript for integration with the
 * Chrome profiler, so none of these C stubs do anything. */

CAMLprim value ppx_module_timer_runtime_mark_start(value description) {
  CAMLparam1(description);
  CAMLreturn(Val_unit);
}

CAMLprim value ppx_module_timer_runtime_mark_end(value unit) {
  CAMLparam1(unit);
  CAMLreturn(Val_unit);
}
