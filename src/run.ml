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
        ("run_command", Jg_types.Tstr (Utils.bold "cln.exe run"));
      ]

let do_dry_run pending =
  let fname = Action.action pending in
  print_endline
    (dry_run_msg ~action_fname:(Fname.to_string fname)
       ~contents:(In_channel.read_all (Fname.to_string fname)))

let do_real_run pending =
  let open Action in
  match run_action pending with
  | Ok () ->
      (* Get completed names. *)
      let completed_action = Utils.pending_to_completed (action pending) in
      let completed_template = Utils.pending_to_completed (template pending) in
      (* Do the move *)
      let () = Fname.move ~source:(action pending) ~target:completed_action in
      let () =
        Fname.move ~source:(template pending) ~target:completed_template
      in
      (* Return the msg *)
      Ok
        (real_run_msg ~pending_action:(action pending) ~completed_action
           ~completed_template)
  | Error exit_code ->
      let msg =
        Printf.sprintf "ERROR (code %d) when running action '%s'" exit_code
          (Fname.to_string (Action.action pending))
      in
      Error (exit_code, msg)

let main ~dry_run =
  let pending = Utils.ok_or_abort (Action.get_pending ()) in
  if dry_run then do_dry_run pending
  else
    match do_real_run pending with
    | Ok msg -> print_endline msg
    | Error (exit_code, msg) -> Utils.abort ~exit_code msg
