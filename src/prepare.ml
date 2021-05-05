open! Core
open Jingoo

let summary_msg ~action ~template =
  let () = assert (Utils.actions_and_templates_ok ~action ~template) in
  let s =
    {heredoc|~~~
~~~
~~~ Hi!  I just prepared an action for you.
~~~
~~~ * The pending action is: '{{ action }}'
~~~ * The git commit template file is: '{{ template }}'
~~~
~~~ Next, you should check the prepared action:
~~~   $ {{ check_action_command }}
~~~
~~~|heredoc}
  in
  let env = { Jg_types.std_env with autoescape = false } in
  Jg_template.from_string ~env s
    ~models:
      [
        ("action", Jg_types.Tstr (Utils.bold (Fname.to_string action)));
        ("template", Jg_types.Tstr (Utils.bold (Fname.to_string template)));
        ("check_action_command", Jg_types.Tstr (Utils.bold "cln run -dry-run"));
      ]

(* If it is a executable on the path, expand it so it is clearer in
   the commit messages. *)
let try_expand_exe_path arg =
  (* Ignore empty things or things that start with a '-' as those are
     probably flags. *)
  if String.length arg = 0 || Char.(String.get arg 0 = '-') then arg
  else
    let cmd = Printf.sprintf "which %s" (Sys.quote arg) in
    let in_chan = Unix.open_process_in cmd in
    let cmd_full_path = Stdio.In_channel.input_all in_chan |> String.strip in
    match Unix.close_process_in in_chan with
    (* Success means it's a command so return the expanded version *)
    | Ok _ -> cmd_full_path
    (* Error means it is not a command on the path. So don't expand it. *)
    | Error _ -> arg

let expand_command cmd =
  let cmd' =
    String.split ~on:' ' cmd
    |> List.map ~f:try_expand_exe_path
    |> String.concat ~sep:" "
  in
  (* Ensure we have a newline. *)
  cmd' ^ "\n"

let write_action_file ~dir ~data ~now =
  let basename = Utils.action_basename data now in
  let fname =
    Fname.make ~dir ~basename ~suffix:(Some Constants.action_suffix)
  in
  let () = Out_channel.write_all (Fname.to_string fname) ~data in
  fname

let write_template_file ~dir ~template_data ~action_data ~now =
  let basename = Utils.action_basename action_data now in
  let fname =
    Fname.make ~dir ~basename ~suffix:(Some Constants.template_suffix)
  in
  let () = Out_channel.write_all (Fname.to_string fname) ~data:template_data in
  fname

(* let write_summary_message ~action ~template =
 *   print_endline (summary_msg ~action ~template) *)

(* Ideally the user runs the actions with the CLI rather than by hand.
   If they do, these won't get out of sync.  But we still check both
   anyway. *)

let deny_pending_actions_exist () =
  match Array.length @@ Sys.readdir Constants.pending_actions_dir with
  | 0 -> ()
  | _ ->
      let () =
        Printf.eprintf
          "ERROR -- there are still pending actions.  You should run them \
           before preparing more.\n"
      in
      exit Exit_code.error

let main action =
  let () = Utils.abort_unless_in_cln_project_root () in
  (* First we ensure no pending stuff is left. *)
  let () = deny_pending_actions_exist () in
  let dir = Utils.assert_dirname_exists Constants.pending_actions_dir in
  (* Now actually set up the action. *)
  let now = Utils.now () in
  let action_data = expand_command action in
  let action = write_action_file ~dir ~data:action_data ~now in
  let template_data = Templates.make_template_data action_data action in
  let template = write_template_file ~dir ~template_data ~now ~action_data in
  print_endline (summary_msg ~action ~template)
