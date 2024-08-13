//Provides:ppx_module_timer_library_names
var ppx_module_timer_library_names = { name:"", start:"", end:"" }

//Provides:ppx_module_timer_module_names
var ppx_module_timer_module_names = { name: "", start: "", end: "" }

//Provides:ppx_module_timer_runtime_mark_start_common
//Requires:caml_jsstring_of_string, ppx_module_timer_library_names, ppx_module_timer_module_names
function ppx_module_timer_runtime_mark_start_common(module_name) {
  // This function doesn't do the conversion from js_of_ocaml-strings to js-strings
  // because it also gets called from wasm.  The javascript function that 
  // applies the conversions is defined at the end of this file
  var lib_name;
  var lib_name__module_name = module_name.split("__");
  if (lib_name__module_name.length === 2) {
    // These prefixes are important to make sure that the library 
    // and module marks are unique
    lib_name = "lib:" + lib_name__module_name[0];
    module_name = "mod:" + lib_name__module_name[1];
  } else {
    // Some module names are just the library name, so we use the 
    // same name for both, but keep using the prefix so that the
    // marks don't double up.
    lib_name = "lib:" + module_name;
    module_name = "mod:" + module_name;
  }

  // This is the point where we see if we've entered a new library
  if (lib_name !== ppx_module_timer_library_names.name) {
    // If the "currently active" library name isn't the empty string,
    // then we need to end that library and measure it
    if (ppx_module_timer_library_names.end !== "") {
      globalThis.performance.mark(ppx_module_timer_library_names.end);
      globalThis.performance.measure(
        ppx_module_timer_library_names.name,
        ppx_module_timer_library_names.start,
        ppx_module_timer_library_names.end);
    }

    // Now we can set the current library name and start measuring
    ppx_module_timer_library_names.name = lib_name;
    ppx_module_timer_library_names.start = lib_name + "_start";
    ppx_module_timer_library_names.end = lib_name + "_end";
    globalThis.performance.mark(ppx_module_timer_library_names.start);
  }

  // Set the names and mark for this module
  ppx_module_timer_module_names.name = module_name;
  ppx_module_timer_module_names.start = module_name + "_start";
  ppx_module_timer_module_names.end = module_name + "_end";
  globalThis.performance.mark(ppx_module_timer_module_names.start);
  return 0;
}

//Provides:ppx_module_timer_runtime_mark_end
//Requires:caml_jsstring_of_string, ppx_module_timer_module_names
function ppx_module_timer_runtime_mark_end() {
  globalThis.performance.mark(ppx_module_timer_module_names.end);
  globalThis.performance.measure(
    ppx_module_timer_module_names.name,
    ppx_module_timer_module_names.start,
    ppx_module_timer_module_names.end);
  return 0;
}

//Provides:ppx_module_timer_runtime_mark_start
//Requires:caml_jsstring_of_string, ppx_module_timer_runtime_mark_start_common
function ppx_module_timer_runtime_mark_start(module_name) {
  var module_name = caml_jsstring_of_string(module_name);
  ppx_module_timer_runtime_mark_start_common(module_name);
  return 0;
}
