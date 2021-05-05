Start in a clean directory.

  $ mkdir WORKING_DIR && cd WORKING_DIR

Try to run an action before you init a new project and you get an
error.

  $ cln run -dry-run
  ERROR -- It doesn't look like you are in a cln project root directory.
    * Did you run `cln init` first.
    * Did you `cd` out of the project directory?
    * Did you run this cln command in a subdirectory of the project root?
  [1]
  $ cln run
  ERROR -- It doesn't look like you are in a cln project root directory.
    * Did you run `cln init` first.
    * Did you `cd` out of the project directory?
    * Did you run this cln command in a subdirectory of the project root?
  [1]

Init a project

  $ cln init Project >/dev/null 2>&1

If you try to run an action but there are none pending, you get an
error.

  $ cln run -dry-run
  ERROR -- there should be one action.  I found 0.
    * Did you prepare an action before running this command?
    * Did you manually move some actions out of the pending directory?
    * Did you manually run actions?
    * Did you manually add actions?
  [1]
  $ cln run
  ERROR -- there should be one action.  I found 0.
    * Did you prepare an action before running this command?
    * Did you manually move some actions out of the pending directory?
    * Did you manually run actions?
    * Did you manually add actions?
  [1]
