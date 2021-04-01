open! Core

type t = { dir : string; basename : string; suffix : string option }

let make ~dir ~basename ~suffix = { dir; basename; suffix }

let update ?dir ?basename ?suffix f =
  {
    dir = Option.value dir ~default:f.dir;
    basename = Option.value basename ~default:f.basename;
    suffix = Option.value suffix ~default:f.suffix;
  }

let of_string s =
  let dir, name = Filename.split s in
  let basename, suffix = Filename.split_extension name in
  { dir; basename; suffix }

let to_string f =
  match f.suffix with
  | Some suffix ->
      Filename.concat f.dir (Printf.sprintf "%s.%s" f.basename suffix)
  | None -> Filename.concat f.dir f.basename

let dir f = f.dir
let basename f = f.basename
let suffix f = f.suffix

(* If /apple/pie.txt -> pie.txt *)
let name f =
  match f.suffix with
  | Some suffix -> Printf.sprintf "%s.%s" f.basename suffix
  | None -> f.basename

let exists f =
  match Sys.file_exists ~follow_symlinks:true (to_string f) with
  | `Yes -> true
  | _ -> false

let move ~source ~target = Sys.rename (to_string source) (to_string target)
