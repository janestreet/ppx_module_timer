open! Core

let hello_world = "Hello, world."

let command =
  Command.basic
    ~summary:hello_world
    (Command.Param.return (fun () -> print_endline hello_world))
;;

let () = Command_unix.run command
