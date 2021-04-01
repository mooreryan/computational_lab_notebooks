type t

(* If we get t Ok back, then we know the template matches the action
   and they both exist, and that they are the only pending pair aka
   we're good to go! *)
val get_pending : unit -> (t, string) result

val run_action : t -> (unit, int) result

val action : t -> Fname.t
val template : t -> Fname.t
