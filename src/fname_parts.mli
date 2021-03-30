type t =
  | WithDir of { dirname : string; name : string }
  | NoDir of { name : string }

val make : string -> t
val to_string : ?default_dirname:string -> t -> string
val name : t -> string
val dirname : t -> string Option.t
