Start in a clean directory.

  $ mkdir WORKING_DIR && cd WORKING_DIR

Set up a git repo.

  $ git init >/dev/null 2>&1

Now this should give an error.

  $ cln init 'New Project'
  ERROR -- Start dir '$TESTCASE_ROOT/WORKING_DIR' should be empty, but found 1 files: '.git'
  [1]
