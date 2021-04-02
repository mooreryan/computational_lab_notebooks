open! Core
open Cln_lib

let version = "0.0.0"

let run cmd = Command.run ~version ~build_info:"Version" cmd

let init_command =
  Command.basic ~summary:"Initialize a new project"
    ~readme:(fun () -> "TODO")
    Command.Let_syntax.(
      let%map_open project_name = anon ("project name" %: string) in
      fun () -> Init.main project_name)

let prepare_command =
  Command.basic ~summary:"Prepare an action"
    ~readme:(fun () -> "TODO")
    Command.Let_syntax.(
      let%map_open action = anon ("action" %: string) in
      fun () -> Prepare.main action)

let run_action_command =
  Command.basic ~summary:"Run an action"
    ~readme:(fun () -> "TODO")
    Command.Let_syntax.(
      let%map_open dry_run =
        flag "-dry-run" no_arg
          ~doc:"Show what we will run, but don't actually run it."
      in
      fun () -> Run_action.main ~dry_run)

let remove_command =
  (* Create a remove method argument parser. *)
  let remove_method_arg =
    Command.Arg_type.create (fun arg ->
        match Remove.remove_method_of_string arg with
        | Some rm_method -> rm_method
        | None ->
            failwith "Remove method must be one of delete, fail, or ignore")
  in
  Command.basic ~summary:"Remove a pending action"
    ~readme:(fun () -> "TODO")
    Command.Let_syntax.(
      let%map_open remove_method =
        flag "-method"
          (required remove_method_arg)
          ~doc:"string How to 'remove'? (delete, fail, or ignore)"
      in
      fun () -> Remove.main ~remove_method)

let command =
  Command.group ~summary:"Git Lab Notebooks"
    ~readme:(fun () ->
      "CLI to help you manage a lab notbook with git and git-annex.")
    [
      ("init", init_command);
      ("prepare", prepare_command);
      ("run-action", run_action_command);
      ("remove", remove_command);
    ]

let () = run command
