open! Core
open Jingoo

type remove_method = Delete | Fail | Ignore

let remove_method_of_string s =
  match s with
  | "delete" -> Some Delete
  | "fail" -> Some Fail
  | "ignore" -> Some Ignore
  | _ -> None

let delete pending =
  let () = pending |> Action.action |> Fname.delete in
  pending |> Action.template |> Fname.delete

let remove pending new_dir =
  let open Action in
  let new_action_f = Fname.update (action pending) ~dir:new_dir in
  let new_template_f = Fname.update (template pending) ~dir:new_dir in
  let () = Fname.move ~source:(action pending) ~target:new_action_f in
  let () = Fname.move ~source:(template pending) ~target:new_template_f in
  (new_action_f, new_template_f)

let remove_msg new_action_f new_template_f =
  let s =
    {heredoc|~~~
~~~
~~~ Hi!  I just removed a pending action for you.
~~~
~~~ * The action is now here '{{ new_action_f }}'.
~~~ * The template is now here '{{ new_template_f }}'.
~~~
~~~ Now, there are a couple of things you should do.
~~~
~~~ * Check which files have changed:
~~~     $ {{ git_status }}
~~~ * Add actions and commit templates (I know it says add--it means "track this change with git"):
~~~     $ {{ git_add }}
~~~ * After "adding" files, commit changes:
~~~     $ {{ git_commit }}
~~~
~~~ You should explain in the commit message why you needed to remove
~~~ the action.  It will help you later when you're going through the
~~~ git logs!
~~~
~~~ After that you are good to go!
~~~
~~~ * You can now check the logs with {{ git_log }},
~~~   or use a GUI like {{ gitk }} to view the history.
~~~
~~~|heredoc}
  in
  let env = { Jg_types.std_env with autoescape = false } in
  Jg_template.from_string ~env s
    ~models:
      [
        ( "new_action_f",
          Jg_types.Tstr (Utils.bold (Fname.to_string new_action_f)) );
        ( "new_template_f",
          Jg_types.Tstr (Utils.bold (Fname.to_string new_template_f)) );
        ("git_add", Jg_types.Tstr (Utils.bold "git add .actions"));
        ("git_commit", Jg_types.Tstr (Utils.bold "git commit"));
        ("git_status", Jg_types.Tstr (Utils.bold "git status"));
        ("git_log", Jg_types.Tstr (Utils.bold "git log"));
        ("gitk", Jg_types.Tstr (Utils.bold "gitk"));
      ]

let delete_msg old_action =
  let s =
    {heredoc|~~~
~~~
~~~ Hi!  I just permanently deleted a pending action for you.
~~~
~~~ Now, there are a couple of things you should do.
~~~
~~~ * Check which files have changed:
~~~     $ {{ git_status }}
~~~ * If you made a mistake, you can still get the files back with
~~~     $ {{ git_checkout_action }}
~~~     $ {{ git_checkout_template }}
~~~ * If not, add actions and commit templates (I know it says add--it means "track this change with git"):
~~~     $ {{ git_add }}
~~~ * After "adding" files, commit changes:
~~~     $ {{ git_commit }}
~~~
~~~ You should explain in the commit message why you needed to remove
~~~ the action.  It will help you later when you're going through the
~~~ git logs!
~~~
~~~ After that you are good to go!
~~~
~~~ * You can now check the logs with {{ git_log }},
~~~   or use a GUI like {{ gitk }} to view the history.
~~~
~~~|heredoc}
  in
  let env = { Jg_types.std_env with autoescape = false } in
  Jg_template.from_string ~env s
    ~models:
      [
        ( "git_checkout_action",
          Jg_types.Tstr
            (Utils.bold "git checkout "
            ^ Fname.to_string (Action.action old_action)) );
        ( "git_checkout_template",
          Jg_types.Tstr
            (Utils.bold "git checkout "
            ^ Fname.to_string (Action.template old_action)) );
        ("git_add", Jg_types.Tstr (Utils.bold "git add .actions"));
        ("git_commit", Jg_types.Tstr (Utils.bold "git commit"));
        ("git_status", Jg_types.Tstr (Utils.bold "git status"));
        ("git_log", Jg_types.Tstr (Utils.bold "git log"));
        ("gitk", Jg_types.Tstr (Utils.bold "gitk"));
      ]

let main ~remove_method =
  let pending = Utils.ok_or_abort (Action.get_pending ()) in
  match remove_method with
  | Delete ->
      let () = delete pending in
      print_endline (delete_msg pending)
  | Fail ->
      let new_action_f, new_template_f =
        remove pending Constants.failed_actions_dir
      in
      print_endline (remove_msg new_action_f new_template_f)
  | Ignore ->
      let new_action_f, new_template_f =
        remove pending Constants.ignored_actions_dir
      in
      print_endline (remove_msg new_action_f new_template_f)

(* START HERE...test this *)
