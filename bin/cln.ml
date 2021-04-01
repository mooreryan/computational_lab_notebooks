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

let command =
  Command.group ~summary:"Git Lab Notebooks"
    ~readme:(fun () ->
      "CLI to help you manage a lab notbook with git and git-annex.")
    [
      ("init", init_command);
      ("prepare", prepare_command);
      ("run-action", run_action_command);
    ]

let () = run command
