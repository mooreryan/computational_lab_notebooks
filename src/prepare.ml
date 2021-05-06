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

(* As of now, it just ensures the command ends in a newline. *)
let prep_command cmd =
  match String.is_suffix cmd ~suffix:"\n" with
  | true -> cmd
  | false -> cmd ^ "\n"

(* Returns the name of the file. *)
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
  let action_data = prep_command action in
  let action_file_name = write_action_file ~dir ~data:action_data ~now in
  let template_data =
    Templates.make_template_data action_data action_file_name
  in
  let template = write_template_file ~dir ~template_data ~now ~action_data in
  print_endline (summary_msg ~action:action_file_name ~template)
