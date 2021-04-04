Change into the work dir. (happy_path_d)

  $ rm -r "${WORK_D}"; mkdir "${WORK_D}"; cd "${WORK_D}"
  * (glob)

Init project

  $ "${CLN_EXE}" init 'Happy Path'
  Initialized empty Git repository in *happy_path_d/.git/ (glob)
  init  (scanning for unlocked files...)
  ok
  (recording state in git...)
  \[master \(root-commit\) [a-z0-9]{7}\] Initial commit (re)
   1 file changed, [0-9]+ insertions\(\+\) (re)
   create mode 100644 README.md
  commit [a-z0-9]+ (re)
  Author: * (glob)
  Date:   * (glob)
  * (glob)
      Initial commit

Make sure the dirs are there.

  $ ls "${WORK_D}/README.md"
  *README.md (glob)
  $ ls -a "${WORK_D}/.actions"
  .
  ..
  completed
  failed
  ignored
  pending

Prepare a good command.

  $ "${CLN_EXE}" prepare 'printf "I like apple pie\n" > msg.txt'
  ~~~
  ~~~
  ~~~ Hi!  I just prepared an action for you.
  ~~~
  ~~~ * The pending action is: '\x1b[1m.actions/pending/action__*.sh\x1b[0m' (esc) (glob)
  ~~~ * The git commit template file is: '\x1b[1m.actions/pending/action__*.gc_template.txt\x1b[0m' (esc) (glob)
  ~~~
  ~~~ Next, you should check the prepared action:
  ~~~   $ \x1b[1mcln run -dry-run\x1b[0m (esc)
  ~~~
  ~~~

Check that the action and template files are there.

  $ ls "${WORK_D}/.actions/pending"
  action__*.gc_template.txt (glob)
  action__*.sh (glob)

Check that the content is correct.

  $ cat "${WORK_D}"/.actions/pending/action__*.gc_template.txt
  PUT COMMIT MSG HERE.
  * (glob)
  == Details ==
  PUT DETAILS HERE.
  * (glob)
  == Command(s) ==
  /*printf "I like apple pie\n" > msg.txt (glob)
  * (glob)
  == Action file ==
  action__*.sh (glob)

Do the dry run (note the spaces again).

  $ "${CLN_EXE}" run -dry-run
  ~~~
  ~~~
  ~~~ Hi!  I just previewed an action for you.
  ~~~
  ~~~ I plan to run this action file:
  ~~~   '\x1b[1m.actions/pending/action__*.sh\x1b[0m' (esc) (glob)
  ~~~
  ~~~ It's contents are:
  ~~~
  \x1b[7m/usr/bin/printf "I like apple pie\\n" > msg.txt (esc)
  \x1b[0m (esc)
  ~~~
  ~~~ If that looks good, you can run the action:
  ~~~   $ \x1b[1mcln run\x1b[0m (esc)
  ~~~
  ~~~
And do the real run.

  $ "${CLN_EXE}" run
  ~~~
  ~~~
  ~~~ Hi!  I just ran an action for you.
  ~~~
  ~~~ * The pending action was '\x1b[1m.actions/pending/action__*.sh\x1b[0m'. (esc) (glob)
  ~~~ * The completed action is '\x1b[1m.actions/completed/action__*.sh\x1b[0m'. (esc) (glob)
  ~~~
  ~~~ Now, there are a couple of things you should do.
  ~~~
  ~~~ * Check which files have changed:
  ~~~     $ \x1b[1mgit status\x1b[0m (esc)
  ~~~ * Add actions and commit templates:
  ~~~     $ \x1b[1mgit add .actions\x1b[0m (esc)
  ~~~ * Unless they are small, add other new files with git annex:
  ~~~     $ \x1b[1mgit annex add blah blah blah...\x1b[0m (esc)
  ~~~ * After adding files, commit changes using the template:
  ~~~     $ \x1b[1mgit commit -t '.actions/completed/action__*.gc_template.txt'\x1b[0m (esc) (glob)
  ~~~
  ~~~ After that you are good to go!
  ~~~
  ~~~ * You can now check the logs with \x1b[1mgit log\x1b[0m, (esc)
  ~~~   or use a GUI like \x1b[1mgitk\x1b[0m to view the history. (esc)
  ~~~
  ~~~

Make sure the action actually ran.

  $ git status
  On branch master
  Untracked files:
    (use "git add <file>..." to include in what will be committed)
  \t.actions/ (esc)
  \tmsg.txt (esc)
  * (glob)
  nothing added to commit but untracked files present (use "git add" to track)

And make sure the file output file from the action is correct.

  $ cat msg.txt
  I like apple pie

Clean up.

  $ cd ${TESTDIR}; rm -r "${WORK_D}"
