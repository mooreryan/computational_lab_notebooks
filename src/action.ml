open! Core

type t = { action : Fname.t; template : Fname.t }

let get_pending_action () =
  let is_pending_action = String.is_suffix ~suffix:Constants.action_suffix in
  let pending_actions =
    Sys.readdir Constants.pending_actions_dir
    |> Array.map ~f:(fun fname ->
           (* Take the dirname back on since readdir doesn't include it. *)
           Filename.concat Constants.pending_actions_dir fname)
    (* We only want the shell scripts.  There will also be a git
       template along with it. *)
    |> Array.filter ~f:is_pending_action
  in
  match Array.length pending_actions with
  | 1 ->
      let fname = Fname.of_string pending_actions.(0) in
      Ok fname
  | n ->
      let msg =
        Printf.sprintf
          "ERROR -- there should be one action.  I found %d.\n\
          \  * Did you prepare an action before running this command?\n\
          \  * Did you manually move some actions out of the pending directory?\n\
          \  * Did you manually run actions?\n\
          \  * Did you manually add actions?" n
      in
      Error msg

(* Given the name of an action file, get its associated git commit
   template. *)
let get_associated_template action =
  let template =
    Fname.make ~dir:(Fname.dir action) ~basename:(Fname.basename action)
      ~suffix:(Some Constants.template_suffix)
  in
  match Sys.file_exists ~follow_symlinks:true (Fname.to_string template) with
  | `Yes -> Ok template
  | _ ->
      let msg =
        Printf.sprintf
          "ERROR -- the associated template file for action '%s' should be \
           '%s', but I cannot find it!"
          (Fname.to_string action) (Fname.to_string template)
      in
      Error msg

let get_pending () =
  get_pending_action ()
  |> Result.bind ~f:(fun action ->
         get_associated_template action
         |> Result.map ~f:(fun template -> { action; template }))

let run_action action =
  let cmd = Printf.sprintf "bash '%s'" (Fname.to_string action.action) in
  match Sys.command cmd with 0 -> Ok () | exit_code -> Error exit_code

let action action = action.action
let template action = action.template
