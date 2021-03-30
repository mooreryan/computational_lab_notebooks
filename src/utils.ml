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
      exit 2

(* Returns a string if dirname exists, aborts otherwise. *)
let deny_dirname_exists dirname =
  match Sys.is_directory ~follow_symlinks:true dirname with
  | `No -> dirname
  | `Yes ->
      let () =
        Printf.eprintf "ERROR -- directory '%s' already exists." dirname
      in
      exit 2
  | `Unknown ->
      let () =
        Printf.eprintf "ERROR -- I can't tell if directory '%s' exists." dirname
      in
      exit 2

let run_cmd_or_abort cmd =
  match Sys.command cmd with
  | 0 -> ()
  | code ->
      let () = Printf.eprintf "ERROR when running %s: %d\n" cmd code in
      exit code

let run_cmds_or_abort cmds = List.iter cmds ~f:run_cmd_or_abort
