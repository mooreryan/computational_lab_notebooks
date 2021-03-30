open! Core

let real_run_msg =
  format_of_string
    {whatever|
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Hi!

* The old action was '%s'.  It is now here: '%s'.
* You should go ahead and run `git status` to see which files changed.
* You probably want to add the actions and commit templates like this:
  git add .actions .commit_templates
* You probably want to add any other files that were created with:
  git annex add <other file 1> <other file 2> ...
  unless those files are pretty small.

* When you commit, use the template: git commit -t '%s'
|whatever}

let dry_run_msg =
  format_of_string
    {whatever|
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
Hi!

I will run this action file: '%s'

It's contents are:

====
====

%s
====
====

If that looks good, then rerun without passing -dry-run.
|whatever}

(* Need to clean up whether things are full filenames or just basename
   or just ... *)

(* This won't have the dirname. *)
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
  | 1 -> Fname_parts.make pending_commit_templates.(0)
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
  Printf.printf real_run_msg
    (Fname_parts.to_string old_action_fname
       ~default_dirname:Constants.pending_actions_dir)
    new_action_fname
    (Fname_parts.to_string pending_commit_template_fname
       ~default_dirname:Constants.commit_templates_dir)

let do_dry_run pending_action_fname =
  let full_path =
    Fname_parts.to_string ~default_dirname:Constants.pending_actions_dir
      pending_action_fname
  in
  Printf.printf dry_run_msg full_path (In_channel.read_all full_path)

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
