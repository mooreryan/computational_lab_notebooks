open! Core
open Jingoo

let real_run_msg ~pending_action ~completed_action ~completed_template =
  let pending_action = Fname.to_string pending_action in
  let completed_action = Fname.to_string completed_action in
  let completed_template = Fname.to_string completed_template in
  let s =
    {heredoc|
~~~
~~~
~~~ Hi!  I just ran an action for you.
~~~
~~~ * The pending action was '{{ pending_action }}'.  
~~~ * The completed action is '{{ completed_action }}'.
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
        ("pending_action", Jg_types.Tstr (Utils.bold pending_action));
        ("completed_action", Jg_types.Tstr (Utils.bold completed_action));
        ("git_add", Jg_types.Tstr (Utils.bold "git add .actions"));
        ( "git_annex",
          Jg_types.Tstr (Utils.bold "git annex add blah blah blah...") );
        ( "git_commit",
          Jg_types.Tstr
            (Utils.bold ("git commit -t '" ^ completed_template ^ "'")) );
        ("git_status", Jg_types.Tstr (Utils.bold "git status"));
        ("git_log", Jg_types.Tstr (Utils.bold "git log"));
        ("gitk", Jg_types.Tstr (Utils.bold "gitk"));
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
        ("action_fname", Jg_types.Tstr (Utils.bold action_fname));
        ("contents", Jg_types.Tstr (Utils.invert contents));
        ("run_command", Jg_types.Tstr (Utils.bold "cln.exe run-action"));
      ]

let do_dry_run pending_action =
  print_endline
    (dry_run_msg
       ~action_fname:(Fname.to_string pending_action)
       ~contents:(In_channel.read_all (Fname.to_string pending_action)))

let do_real_run ~pending_action ~pending_template =
  match Action.run_action pending_action with
  | Ok () ->
      let completed_action = Utils.pending_to_completed pending_action in
      let completed_template = Utils.pending_to_completed pending_template in
      let () = Fname.move ~source:pending_action ~target:completed_action in
      let () = Fname.move ~source:pending_template ~target:completed_template in
      Ok (real_run_msg ~pending_action ~completed_action ~completed_template)
  | Error exit_code ->
      let msg =
        Printf.sprintf "ERROR (code %d) when running action '%s'" exit_code
          (Fname.to_string pending_action)
      in
      Error (exit_code, msg)

let main ~dry_run =
  let pending_action = Utils.ok_or_abort (Action.get_pending_action ()) in
  let pending_template =
    Utils.ok_or_abort (Action.get_associated_template pending_action)
  in
  if dry_run then do_dry_run pending_action
  else
    match do_real_run ~pending_action ~pending_template with
    | Ok msg -> print_endline msg
    | Error (exit_code, msg) -> Utils.abort ~exit_code msg
