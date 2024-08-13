(module
   (import "env" "wrap" (func $wrap (param anyref) (result (ref eq))))
   (import "env" "unwrap" (func $unwrap (param (ref eq)) (result anyref)))
   (import "env" "caml_jsstring_of_string"
      (func $caml_jsstring_of_string (param (ref eq)) (result (ref eq))))

   (import "js" "ppx_module_timer_runtime_mark_start_common"
      (func $ppx_module_timer_runtime_mark_start_common
         (param anyref) (result anyref)))

   (import "js" "ppx_module_timer_runtime_mark_end"
      (func $ppx_module_timer_runtime_mark_end_common
         (param anyref) (result anyref)))


   (func (export "ppx_module_timer_runtime_mark_start")
      (param $module_name (ref eq)) (result (ref eq))
      (return_call $wrap
         (call $ppx_module_timer_runtime_mark_start_common
            (call $unwrap
               (call $caml_jsstring_of_string (local.get $module_name))))))

   (func (export "ppx_module_timer_runtime_mark_end")
      (param $unit (ref eq)) (result (ref eq))
      (return_call $wrap
         (call $ppx_module_timer_runtime_mark_end_common (call $unwrap (local.get $unit)))))
)
