open! Core

let now () =
  let t = Unix.localtime @@ Unix.gettimeofday () in
  Unix.strftime t "%F_%T"

(* Returns a string if dirname exists, aborts otherwise. *)
let assert_dirname_exists dirname =
  match Sys.is_directory ~follow_symlinks:true dirname with
  | `Yes -> dirname
  | _ ->
      let () =
        Printf.eprintf
          "ERROR -- Cannot find '%s' directory. Ary you at the project root?\n"
          dirname
      in
      exit Exit_code.error

(* Returns a string if dirname exists, aborts otherwise. *)
let deny_dirname_exists dirname =
  match Sys.is_directory ~follow_symlinks:true dirname with
  | `No -> dirname
  | `Yes ->
      let () =
        Printf.eprintf "ERROR -- directory '%s' already exists.\n" dirname
      in
      exit Exit_code.error
  | `Unknown ->
      let () =
        Printf.eprintf "ERROR -- I can't tell if directory '%s' exists.\n"
          dirname
      in
      exit Exit_code.error

let run_cmd_or_abort cmd =
  match Sys.command cmd with
  | 0 -> ()
  | code ->
      let () = Printf.eprintf "ERROR when running %s: %d\n" cmd code in
      exit code

let run_cmds_or_abort cmds = List.iter cmds ~f:run_cmd_or_abort

let abort ?(exit_code = Exit_code.error) msg =
  let () = Printf.eprintf "%s\n" msg in
  exit exit_code

let ok_or_abort ?(exit_code = Exit_code.error) result =
  match result with Ok x -> x | Error msg -> abort ~exit_code msg

let bold s = Printf.sprintf "\x1B[1m%s\x1B[0m" s
let _dim s = Printf.sprintf "\x1B[2m%s\x1B[0m" s
let _underline s = Printf.sprintf "\x1B[4m%s\x1B[0m" s
let _blink s = Printf.sprintf "\x1B[5m%s\x1B[0m" s
let invert s = Printf.sprintf "\x1B[7m%s\x1B[0m" s

let action_basename data created_at =
  Printf.sprintf "action__%d__%s" (String.hash data) created_at

let action_and_template_match ~action ~template =
  let open Fname in
  let dirs_match = String.equal (dir action) (dir template) in
  let basenames_match = String.equal (basename action) (basename template) in
  dirs_match && basenames_match

(* Do they match and do they exist? *)
let actions_and_templates_ok ~action ~template =
  let they_match = action_and_template_match ~action ~template in
  they_match && Fname.exists action && Fname.exists template

(* Convert pending fname to a completed fname *)
let pending_to_completed fname =
  Fname.update fname ~dir:Constants.completed_actions_dir

let is_cln_project_root dirname =
  let open Constants in
  List.fold
    [
      actions_dirname;
      pending_actions_dir;
      completed_actions_dir;
      failed_actions_dir;
      ignored_actions_dir;
      ".git";
    ] ~init:true ~f:(fun acc name ->
      let dir = Filename.concat dirname name in
      match Sys.is_directory dir with `Yes -> acc && true | _ -> acc && false)

let abort_unless_in_cln_project_root () =
  let cwd = Sys.getcwd () in
  match is_cln_project_root cwd with
  | true -> ()
  | false ->
      abort
        "ERROR -- it doesn't look like you are in a cln project root directory"
