Make redaction helper.

  $ printf "sed -E 's~action__(.*).sh~action__REDACTED.sh~' | sed -E 's~action__(.*).gc_template.txt~action__REDACTED.gc_template.txt~'\n" > redact.sh

Start in a clean directory.

  $ mkdir WORKING_DIR && cd WORKING_DIR

Try to prepare a command before you init a new project and you get an
error.

  $ cln prepare 'echo "hi"'
  ERROR -- It doesn't look like you are in a cln project root directory.
    * Did you run `cln init` first.
    * Did you `cd` out of the project directory?
    * Did you run this cln command in a subdirectory of the project root?
  [1]

Now, set up a project and prepare an action.

  $ cln init Project >/dev/null 2>&1
  $ cln prepare 'printf "say hi\n"' | bash ../redact.sh
  ~~~
  ~~~
  ~~~ Hi!  I just prepared an action for you.
  ~~~
  ~~~ * The pending action is: '.actions/pending/action__REDACTED.sh'
  ~~~ * The git commit template file is: '.actions/pending/action__REDACTED.gc_template.txt'
  ~~~
  ~~~ Next, you should check the prepared action:
  ~~~   $ cln run -dry-run
  ~~~
  ~~~
  $ cat .actions/pending/*.sh
  printf "say hi\n"


