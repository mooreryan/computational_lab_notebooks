open! Core
open Cln_lib

let version = "0.2.1"

let init_command =
  Command.basic ~summary:Cli_help.init_summary ~readme:Cli_help.init_readme
    Command.Let_syntax.(
      let%map_open project_name = anon ("project_name" %: string) in
      fun () -> Init.main project_name)

let prepare_command =
  Command.basic ~summary:Cli_help.prepare_summary
    ~readme:Cli_help.prepare_readme
    Command.Let_syntax.(
      let%map_open action = anon ("action" %: string) in
      fun () -> Prepare.main action)

let run_command =
  Command.basic ~summary:Cli_help.run_summary ~readme:Cli_help.run_readme
    Command.Let_syntax.(
      let%map_open dry_run =
        flag "-dry-run" no_arg
          ~doc:"Show what we will run, but don't actually run it."
      in
      fun () -> Run.main ~dry_run)

let remove_command =
  (* Create a remove method argument parser. *)
  let remove_method_arg =
    Command.Arg_type.create (fun arg ->
        match Remove.remove_method_of_string arg with
        | Some rm_method -> rm_method
        | None ->
            failwith "Remove method must be one of delete, fail, or ignore")
  in
  Command.basic ~summary:Cli_help.remove_summary ~readme:Cli_help.remove_readme
    Command.Let_syntax.(
      let%map_open remove_method =
        flag "-method"
          (required remove_method_arg)
          ~doc:"string How to 'remove'? (delete, fail, or ignore)"
      in
      fun () -> Remove.main ~remove_method)

let command =
  Command.group ~summary:"Computational Lab Notebooks"
    ~readme:(fun () ->
      "CLI to help you manage a lab notbook with git and git-annex.")
    [
      ("init", init_command);
      ("prepare", prepare_command);
      ("run", run_command);
      ("remove", remove_command);
    ]

let () = Command.run ~version ~build_info:"" command
