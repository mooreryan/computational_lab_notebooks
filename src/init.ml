open! Core

let abort_unless_start_dir_is_empty () =
  let cwd = Sys.getcwd () in
  let filenames = Sys.readdir cwd in
  match Array.length filenames with
  | 0 -> ()
  | n ->
      let names = String.concat (Array.to_list filenames) ~sep:", " in
      Utils.abort
        (Printf.sprintf
           "ERROR -- Start dir '%s' should be empty, but found %d files: '%s'"
           cwd n names)

let make_project_dirs () =
  let actions_dir = Utils.deny_dirname_exists Constants.actions_dirname in
  let pending_actions_dir =
    Utils.deny_dirname_exists Constants.pending_actions_dir
  in
  let completed_actions_dir =
    Utils.deny_dirname_exists Constants.completed_actions_dir
  in
  let failed_actions_dir =
    Utils.deny_dirname_exists Constants.failed_actions_dir
  in
  let ignored_actions_dir =
    Utils.deny_dirname_exists Constants.ignored_actions_dir
  in
  let _git_dir = Utils.deny_dirname_exists ".git" in
  [
    actions_dir;
    pending_actions_dir;
    completed_actions_dir;
    failed_actions_dir;
    ignored_actions_dir;
  ]
  |> List.iter ~f:Unix.mkdir

let write_readme project_name =
  Out_channel.write_all "README.md"
    ~data:(Templates.make_readme_data project_name)

let run_git_setup () =
  let cmds =
    [
      "git init";
      "git annex init";
      "git add .";
      "git commit -m 'Initial commit'";
      "git log";
    ]
  in
  Utils.run_cmds_or_abort cmds

let main project_name =
  let () = abort_unless_start_dir_is_empty () in
  let () = make_project_dirs () in
  let () = write_readme project_name in
  run_git_setup ()
