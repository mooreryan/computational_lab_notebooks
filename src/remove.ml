open! Core

let x = 1

type remove_method = Delete | Fail | Ignore

let delete_action () = print_endline "delete"
let fail_action () = print_endline "fail"
let ignore_action () = print_endline "ignore"

let main ~remove_method =
  match remove_method with
  | Delete -> delete_action ()
  | Fail -> fail_action ()
  | Ignore -> ignore_action ()
