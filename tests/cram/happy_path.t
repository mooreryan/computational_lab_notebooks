Make redaction helper.

  $ printf "sed -E 's~action__(.*).sh~action__REDACTED.sh~' | sed -E 's~action__(.*).gc_template.txt~action__REDACTED.gc_template.txt~'\n" > redact.sh

Start in a clean directory.

  $ mkdir WORKING_DIR && cd WORKING_DIR

Initialize a new project.

  $ cln init 'Happy Path' >../OUT 2>&1
  $ grep -iq 'Initialized empty Git repository' ../OUT
  $ grep -iq 'Initial commit' ../OUT
  $ grep -iq '# Happy Path' README.md
  $ ls >/dev/null 2>&1 .git
  $ ls -1 .actions
  completed
  failed
  ignored
  pending

Prepare a good command.

  $ cln prepare 'printf "I like apple pie\n" > msg.txt' | bash ../redact.sh
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
  $ ls .actions/pending | bash ../redact.sh
  action__REDACTED.gc_template.txt
  action__REDACTED.sh
  $ cat .actions/pending/*.sh
  printf "I like apple pie\n" > msg.txt
  $ cat .actions/pending/*.gc_template.txt | bash ../redact.sh
  PUT COMMIT MSG HERE.
  
  == Details ==
  PUT DETAILS HERE.
  
  == Command(s) ==
  printf "I like apple pie\n" > msg.txt
  
  == Action file ==
  action__REDACTED.sh

Do the dry run.

  $ cln run -dry-run | bash ../redact.sh
  ~~~
  ~~~
  ~~~ Hi!  I just previewed an action for you.
  ~~~
  ~~~ I plan to run this action file:
  ~~~   '.actions/pending/action__REDACTED.sh'
  ~~~
  ~~~ It's contents are:
  ~~~
  printf "I like apple pie\n" > msg.txt
  
  ~~~
  ~~~ If that looks good, you can run the action:
  ~~~   $ cln run
  ~~~
  ~~~

The job should not have run yet.

  $ cat msg.txt 2>/dev/null
  [1]

Do the real run.

  $ cln run | bash ../redact.sh
  ~~~
  ~~~
  ~~~ Hi!  I just ran an action for you.
  ~~~
  ~~~ * The pending action was '.actions/pending/action__REDACTED.sh'.
  ~~~ * The completed action is '.actions/completed/action__REDACTED.sh'.
  ~~~
  ~~~ Now, there are a couple of things you should do.
  ~~~
  ~~~ * Check which files have changed:
  ~~~     $ git status
  ~~~ * Add actions and commit templates:
  ~~~     $ git add .actions
  ~~~ * Unless they are small, add other new files with git annex:
  ~~~     $ git annex add blah blah blah...
  ~~~ * After adding files, commit changes using the template:
  ~~~     $ git commit -t '.actions/completed/action__REDACTED.gc_template.txt'
  ~~~
  ~~~ After that you are good to go!
  ~~~
  ~~~ * You can now check the logs with git log,
  ~~~   or use a GUI like gitk to view the history.
  ~~~
  ~~~

And now the job should have run.

  $ cat msg.txt
  I like apple pie
