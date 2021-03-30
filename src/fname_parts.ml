open! Core

type t =
  | WithDir of { dirname : string; name : string }
  | NoDir of { name : string }

let make s =
  match Filename.split s with
  | ".", name -> NoDir { name }
  | dir, name -> WithDir { dirname = dir; name }

let to_string ?default_dirname fname =
  match fname with
  | WithDir { dirname; name } -> Filename.concat dirname name
  | NoDir { name } -> (
      match default_dirname with
      | None -> name
      | Some default_dirname' -> Filename.concat default_dirname' name)

let name = function WithDir x -> x.name | NoDir { name } -> name

let dirname = function WithDir x -> Some x.dirname | NoDir _ -> None
