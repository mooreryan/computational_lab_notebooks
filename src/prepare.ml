open! Core
open Jingoo

let bold s = Printf.sprintf "\x1B[1m%s\x1B[0m" s

let summary_msg ~action_fname ~commit_fname =
  let s =
    {heredoc|
~~~ 
~~~ 
~~~ Hi!  I just prepared an action for you.
~~~ 
~~~ * The pending action is: '{{ action_fname }}'
~~~ * The git commit template file is: '{{ commit_fname }}'
~~~
~~~ Next, you should check the prepared action: 
~~~     $ {{ check_action_command }}
~~~ 
~~~ 
|heredoc}
  in
  let env = { Jg_types.std_env with autoescape = false } in
  Jg_template.from_string ~env s
    ~models:
      [
        ("action_fname", Jg_types.Tstr (bold action_fname));
        ("commit_fname", Jg_types.Tstr (bold commit_fname));
        ( "check_action_command",
          Jg_types.Tstr (bold "gln.exe run-action -dry-run") );
      ]

(* If it is a executable on the path, expand it so it is clearer in
   the commit messages. *)
let try_expand_exe_path arg =
  (* Ignore empty things or things that start with a '-' as those are
     probably flags. *)
  if String.length arg = 0 || Char.(String.get arg 0 = '-') then arg
  else
    let cmd = Printf.sprintf "which %s" (Sys.quote arg) in
    (* let () = print_endline cmd in *)
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

let write_action_file data now =
  let actions_dir = Utils.assert_dirname_exists Constants.pending_actions_dir in
  let fname =
    Filename.concat actions_dir
      (Printf.sprintf "action__%d__%s.sh" (String.hash data) now)
  in
  let () = Out_channel.write_all fname ~data in
  Fname_parts.make fname

let write_commit_template_file data now action_data =
  let templates_dir =
    Utils.assert_dirname_exists Constants.commit_templates_dir
  in
  let fname =
    Filename.concat templates_dir
      (Printf.sprintf "template_for__action__%d__%s.txt"
         (String.hash action_data) now)
  in
  let () = Out_channel.write_all fname ~data in
  Fname_parts.make fname

let write_summary_message ~action_fname ~commit_template_fname =
  let action_fname' =
    Fname_parts.to_string ~default_dirname:Constants.pending_actions_dir
      action_fname
  in
  let commit_template_fname' =
    Fname_parts.to_string ~default_dirname:Constants.commit_templates_dir
      commit_template_fname
  in
  print_endline
    (summary_msg ~action_fname:action_fname'
       ~commit_fname:commit_template_fname')

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
      exit 1

let main action =
  (* First we ensure no pending stuff is left. *)
  let () = deny_pending_actions_exist () in

  (* Now actually set up the action. *)
  let now = Utils.now () in
  let action_data = expand_command action in
  let action_fname = write_action_file action_data now in
  let template_data =
    Templates.make_commit_template_data action_data action_fname
  in
  let commit_template_fname =
    write_commit_template_file template_data now action_data
  in
  write_summary_message ~action_fname ~commit_template_fname
