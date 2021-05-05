Start in a clean directory.

  $ mkdir WORKING_DIR && cd WORKING_DIR

Put a file in this dir.

  $ printf "test\n" > test.txt

Now, `cln init` should fail.

  $ cln init Project
  ERROR -- Start dir '$TESTCASE_ROOT/WORKING_DIR' should be empty, but found 1 files: 'test.txt'
  [1]
