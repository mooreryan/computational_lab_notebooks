open! Core
open Jingoo

let bold s = Printf.sprintf "\x1B[1m%s\x1B[0m" s
let _dim s = Printf.sprintf "\x1B[2m%s\x1B[0m" s
let _underline s = Printf.sprintf "\x1B[4m%s\x1B[0m" s
let _blink s = Printf.sprintf "\x1B[5m%s\x1B[0m" s
let invert s = Printf.sprintf "\x1B[7m%s\x1B[0m" s

let real_run_msg ~old_action ~new_action ~commit_template =
  let s =
    {heredoc|
~~~
~~~
~~~ Hi!  I just ran an action for you.
~~~
~~~ * The pending action was '{{ old_action }}'.  
~~~ * The completed action is '{{ new_action }}'.
~~~
~~~ Now, there are a couple of things you should do.
~~~
~~~ * Check which files have changed:
~~~     $ {{ git_status }}
~~~ * Add actions and commit templates:
~~~     $ {{ git_add }}
~~~ * Unless they are small, add other new files with git annex:
~~~     $ {{ git_annex }}
~~~ * After adding files, commit changes using the template:
~~~     $ {{ git_commit }}
~~~
~~~ After that you are good to go!  
~~~ 
~~~ * You can now check the logs with {{ git_log }},
~~~   or use a GUI like {{ gitk }} to view the history.
~~~
|heredoc}
  in
  let env = { Jg_types.std_env with autoescape = false } in
  Jg_template.from_string ~env s
    ~models:
      [
        ("old_action", Jg_types.Tstr (bold old_action));
        ("new_action", Jg_types.Tstr (bold new_action));
        ("git_add", Jg_types.Tstr (bold "git add .actions .commit_templates"));
        ("git_annex", Jg_types.Tstr (bold "git annex add blah blah blah..."));
        ( "git_commit",
          Jg_types.Tstr (bold ("git commit -t '" ^ commit_template ^ "'")) );
        ("git_status", Jg_types.Tstr (bold "git status"));
        ("git_log", Jg_types.Tstr (bold "git log"));
        ("gitk", Jg_types.Tstr (bold "gitk"));
      ]

let dry_run_msg ~action_fname ~contents =
  let s =
    {heredoc|
~~~ 
~~~
~~~ Hi!  I just previewed an action for you.
~~~ 
~~~ I plan to run this action file: 
~~~   '{{ action_fname }}'
~~~ 
~~~ It's contents are:
~~~ 
{{ contents }}
~~~ 
~~~ If that looks good, you can run the action:
~~~   $ {{ run_command }}
~~~ 
~~~ 
|heredoc}
  in
  let env = { Jg_types.std_env with autoescape = false } in
  Jg_template.from_string ~env s
    ~models:
      [
        ("action_fname", Jg_types.Tstr (bold action_fname));
        ("contents", Jg_types.Tstr (invert contents));
        ("run_command", Jg_types.Tstr (bold "gln.exe run-action"));
      ]

let get_pending_action_fname () =
  let pending_actions = Sys.readdir Constants.pending_actions_dir in
  match Array.length pending_actions with
  | 1 -> Fname_parts.make pending_actions.(0)
  | n ->
      let () =
        Printf.eprintf
          "ERROR -- there should be one action.  I found %d.  Did you manually \
           move some actions out of the pending directory?  Did you manually \
           run actions?  Did you manually add actions?\n"
          n
      in
      exit 1

let get_pending_commit_template_fname pending_action_fname =
  (* let _, action_basename_with_ext = Filename.split pending_action_fname in *)
  let action_basename, _ =
    Filename.split_extension (Fname_parts.name pending_action_fname)
  in
  let pending_commit_templates = Sys.readdir Constants.commit_templates_dir in
  let matching_commit_templates =
    (* We want to make sure that only one of the git templates matches the action. *)
    Array.filter pending_commit_templates ~f:(fun commit_template_fname ->
        (* .commit_templates/template_for__action__1063928644__2021-03-30_00:18:32.txt *)
        String.is_substring ~substring:action_basename commit_template_fname)
  in
  match Array.length matching_commit_templates with
  | 1 -> Fname_parts.make matching_commit_templates.(0)
  | n ->
      let () =
        Printf.eprintf
          "ERROR -- more than one (%d) git commit template matched for the \
           pending action.  Did you make some commit templates by hand?\n"
          n
      in
      exit 1

let run_action action_fname =
  let full_action_fname =
    Fname_parts.to_string ~default_dirname:Constants.pending_actions_dir
      action_fname
  in
  let cmd = Printf.sprintf "bash '%s'" full_action_fname in
  match Sys.command cmd with
  | 0 ->
      let completed_action_fname =
        Filename.concat Constants.completed_actions_dir
          (Fname_parts.name action_fname)
      in
      let () = Sys.rename full_action_fname completed_action_fname in
      completed_action_fname
  | code ->
      let () =
        Printf.eprintf
          "ERROR when running %s: %d\n\nThe problematic action file is '%s'\n"
          cmd code full_action_fname
      in
      exit 1

let print_real_run_message old_action_fname new_action_fname
    pending_commit_template_fname =
  let old_action =
    Fname_parts.to_string old_action_fname
      ~default_dirname:Constants.pending_actions_dir
  in
  let new_action = new_action_fname in
  let commit_template =
    Fname_parts.to_string pending_commit_template_fname
      ~default_dirname:Constants.commit_templates_dir
  in
  print_endline (real_run_msg ~old_action ~new_action ~commit_template)

let do_dry_run pending_action_fname =
  let full_path =
    Fname_parts.to_string ~default_dirname:Constants.pending_actions_dir
      pending_action_fname
  in
  print_endline
    (dry_run_msg ~action_fname:full_path
       ~contents:(In_channel.read_all full_path))

let do_real_run ~pending_action_fname ~pending_commit_template_fname =
  let completed_action_fname = run_action pending_action_fname in
  print_real_run_message pending_action_fname completed_action_fname
    pending_commit_template_fname

let main ~dry_run =
  let pending_action_fname = get_pending_action_fname () in
  let pending_commit_template_fname =
    get_pending_commit_template_fname pending_action_fname
  in
  if dry_run then do_dry_run pending_action_fname
  else do_real_run ~pending_action_fname ~pending_commit_template_fname
