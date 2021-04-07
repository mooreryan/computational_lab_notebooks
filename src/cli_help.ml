let docs_url = "https://mooreryan.github.io/cln_docs/"

(* The `msg` should have a newline at the front and the back. *)
let readme msg = "=== info ===\n" ^ msg ^ "\nFor more info, see " ^ docs_url

let init_summary = "Initialize a new project"
let init_readme () =
  readme
    {heredoc|
Initialize a new computational lab notebook project using git and
git-annex.
|heredoc}

let prepare_summary = "Prepare an action"
let prepare_readme () =
  readme
    {heredoc|
Generates an action file and a git commit template in the
'<project_root>/.actions/pending' directory.
|heredoc}

let run_summary = "Run an action"
let run_readme () =
  readme
    {heredoc|
If the run is successful, the pending action and the git commit
will be moved in to the '<project_root>/.actions/pending'
directory.
|heredoc}

let remove_summary = "Remove a pending action"
let remove_readme () =
  readme
    {heredoc|
If there is a pending action, this will 'remove' it.

There are three ways to remove pending actions: 1) delete them, 2)
move them into the ignored directory, and 3) move them into the failed
directory.  Use whichever one makes the most sense for why you need to
remove them.
|heredoc}
