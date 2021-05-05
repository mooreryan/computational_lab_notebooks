Make redaction helper.

  $ printf "sed -E 's~action__(.*).sh~action__REDACTED.sh~' | sed -E 's~action__(.*).gc_template.txt~action__REDACTED.gc_template.txt~'\n" > redact.sh

Start in a clean directory.

  $ mkdir WORKING_DIR && cd WORKING_DIR

Try to remove an action before initializing a project and you get an
error.

  $ cln remove -method delete
  ERROR -- it doesn't look like you are in a cln project root directory
  [1]
  $ cln remove -method fail
  ERROR -- it doesn't look like you are in a cln project root directory
  [1]
  $ cln remove -method ignore
  ERROR -- it doesn't look like you are in a cln project root directory
  [1]

Set up.

  $ cln init something >/dev/null 2>&1

Try to remove an action before creating one and you get an error.

  $ cln remove -method delete
  ERROR -- there should be one action.  I found 0.
    * Did you prepare an action before running this command?
    * Did you manually move some actions out of the pending directory?
    * Did you manually run actions?
    * Did you manually add actions?
  [1]
  $ cln remove -method fail
  ERROR -- there should be one action.  I found 0.
    * Did you prepare an action before running this command?
    * Did you manually move some actions out of the pending directory?
    * Did you manually run actions?
    * Did you manually add actions?
  [1]
  $ cln remove -method ignore
  ERROR -- there should be one action.  I found 0.
    * Did you prepare an action before running this command?
    * Did you manually move some actions out of the pending directory?
    * Did you manually run actions?
    * Did you manually add actions?
  [1]


Now prepare an action.

  $ cln prepare 'printf "I like apple pie\n" > msg.txt' >/dev/null 2>&1
  $ ls .actions/pending | bash ../redact.sh
  action__REDACTED.gc_template.txt
  action__REDACTED.sh

Delete the prepared action.

  $ cln remove -method delete | bash ../redact.sh
  ~~~
  ~~~
  ~~~ Hi!  I just permanently deleted a pending action for you.
  ~~~
  ~~~ Now, there are a couple of things you should do.
  ~~~
  ~~~ * Check which files have changed:
  ~~~     $ git status
  ~~~ * If you made a mistake, you can still get the files back with
  ~~~     $ git checkout .actions/pending/action__REDACTED.sh
  ~~~     $ git checkout .actions/pending/action__REDACTED.gc_template.txt
  ~~~ * If not, add actions and commit templates (I know it says add--it means "track this change with git"):
  ~~~     $ git add .actions
  ~~~ * After "adding" files, commit changes:
  ~~~     $ git commit
  ~~~
  ~~~ You should explain in the commit message why you needed to remove
  ~~~ the action.  It will help you later when you're going through the
  ~~~ git logs!
  ~~~
  ~~~ After that you are good to go!
  ~~~
  ~~~ * You can now check the logs with git log,
  ~~~   or use a GUI like gitk to view the history.
  ~~~
  ~~~

Check that the action is gone.

  $ ls .actions/pending

Prepare another action and move it to the failed directory.

  $ cln prepare 'printf "I like apple pie\n" > msg.txt' >/dev/null 2>&1
  $ cln remove -method fail | bash ../redact.sh
  ~~~
  ~~~
  ~~~ Hi!  I just removed a pending action for you.
  ~~~
  ~~~ * The action is now here '.actions/failed/action__REDACTED.sh'.
  ~~~ * The template is now here '.actions/failed/action__REDACTED.gc_template.txt'.
  ~~~
  ~~~ Now, there are a couple of things you should do.
  ~~~
  ~~~ * Check which files have changed:
  ~~~     $ git status
  ~~~ * Add actions and commit templates (I know it says add--it means "track this change with git"):
  ~~~     $ git add .actions
  ~~~ * After "adding" files, commit changes:
  ~~~     $ git commit
  ~~~
  ~~~ You should explain in the commit message why you needed to remove
  ~~~ the action.  It will help you later when you're going through the
  ~~~ git logs!
  ~~~
  ~~~ After that you are good to go!
  ~~~
  ~~~ * You can now check the logs with git log,
  ~~~   or use a GUI like gitk to view the history.
  ~~~
  ~~~

The action should now be in the "failed" directory and nothing should
be in the pending directory.

  $ ls .actions/pending
  $ ls .actions/failed | bash ../redact.sh
  action__REDACTED.gc_template.txt
  action__REDACTED.sh

Prep another action then move it to "ignored" directory.

  $ cln prepare 'printf "I like apple pie\n" > msg.txt' >/dev/null 2>&1
  $ cln remove -method ignore | bash ../redact.sh
  ~~~
  ~~~
  ~~~ Hi!  I just removed a pending action for you.
  ~~~
  ~~~ * The action is now here '.actions/ignored/action__REDACTED.sh'.
  ~~~ * The template is now here '.actions/ignored/action__REDACTED.gc_template.txt'.
  ~~~
  ~~~ Now, there are a couple of things you should do.
  ~~~
  ~~~ * Check which files have changed:
  ~~~     $ git status
  ~~~ * Add actions and commit templates (I know it says add--it means "track this change with git"):
  ~~~     $ git add .actions
  ~~~ * After "adding" files, commit changes:
  ~~~     $ git commit
  ~~~
  ~~~ You should explain in the commit message why you needed to remove
  ~~~ the action.  It will help you later when you're going through the
  ~~~ git logs!
  ~~~
  ~~~ After that you are good to go!
  ~~~
  ~~~ * You can now check the logs with git log,
  ~~~   or use a GUI like gitk to view the history.
  ~~~
  ~~~

Check that the action has moved.

  $ ls .actions/pending
  $ ls .actions/ignored | bash ../redact.sh
  action__REDACTED.gc_template.txt
  action__REDACTED.sh
