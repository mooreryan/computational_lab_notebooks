open! Core

let make_commit_template_data action action_fname =
  Printf.sprintf
    {whatever|PUT COMMIT MSG HERE.

== Details ==
PUT DETAILS HERE.

== Command(s) ==
%s

== Action file ==
%s
|whatever}
    action
    (Fname_parts.name action_fname)

let make_readme_data project_name =
  Printf.sprintf
    {whatever|# %s

* Actions are in `.actions`.
* Git commit templates are in `.commit_templates`.
* Use `prepare.exe` to prepare your migrations.
* Add big files with `git annex add` and normal files with `git add`.

Have fun!
|whatever}
    project_name
