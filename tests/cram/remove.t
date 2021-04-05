Set up.

  $ rm -r "${WORK_D}" >/dev/null 2>&1; mkdir "${WORK_D}"; cd "${WORK_D}"
  $ "${CLN_EXE}" init 'something' >/dev/null 2>&1
  $ "${CLN_EXE}" prepare 'printf "I like apple pie\n" > msg.txt' >/dev/null 2>&1

Double check the setup was good.

  $ ls "${WORK_D}/.actions/pending"
  action__*.gc_template.txt (glob)
  action__*.sh (glob)

Delete the prepared action.

  $ "${CLN_EXE}" remove -method delete
  ~~~
  ~~~
  ~~~ Hi!  I just permanently deleted a pending action for you.
  ~~~
  ~~~ Now, there are a couple of things you should do.
  ~~~
  ~~~ * Check which files have changed:
  ~~~     $ \x1b[1mgit status\x1b[0m (esc)
  ~~~ * If you made a mistake, you can still get the files back with
  ~~~     $ \x1b[1mgit checkout \x1b[0m.actions/pending/action__*.sh (esc) (glob)
  ~~~     $ \x1b[1mgit checkout \x1b[0m.actions/pending/action__*.gc_template.txt (esc) (glob)
  ~~~ * If not, add actions and commit templates (I know it says add--it means "track this change with git"):
  ~~~     $ \x1b[1mgit add .actions\x1b[0m (esc)
  ~~~ * After "adding" files, commit changes:
  ~~~     $ \x1b[1mgit commit\x1b[0m (esc)
  ~~~
  ~~~ You should explain in the commit message why you needed to remove
  ~~~ the action.  It will help you later when you're going through the
  ~~~ git logs!
  ~~~
  ~~~ After that you are good to go!
  ~~~
  ~~~ * You can now check the logs with \x1b[1mgit log\x1b[0m, (esc)
  ~~~   or use a GUI like \x1b[1mgitk\x1b[0m to view the history. (esc)
  ~~~
  ~~~

And check that it is actually gone.

  $ ls "${WORK_D}/.actions/pending"

Prepare another action.

  $ "${CLN_EXE}" prepare 'printf "I like apple pie\n" > msg.txt' >/dev/null 2>&1

Move the pending action to failed action directory.

  $ "${CLN_EXE}" remove -method fail
  ~~~
  ~~~
  ~~~ Hi!  I just removed a pending action for you.
  ~~~
  ~~~ * The action is now here '\x1b[1m.actions/failed/action__*.sh\x1b[0m'. (esc) (glob)
  ~~~ * The template is now here '\x1b[1m.actions/failed/action__*.gc_template.txt\x1b[0m'. (esc) (glob)
  ~~~
  ~~~ Now, there are a couple of things you should do.
  ~~~
  ~~~ * Check which files have changed:
  ~~~     $ \x1b[1mgit status\x1b[0m (esc)
  ~~~ * Add actions and commit templates (I know it says add--it means "track this change with git"):
  ~~~     $ \x1b[1mgit add .actions\x1b[0m (esc)
  ~~~ * After "adding" files, commit changes:
  ~~~     $ \x1b[1mgit commit\x1b[0m (esc)
  ~~~
  ~~~ You should explain in the commit message why you needed to remove
  ~~~ the action.  It will help you later when you're going through the
  ~~~ git logs!
  ~~~
  ~~~ After that you are good to go!
  ~~~
  ~~~ * You can now check the logs with \x1b[1mgit log\x1b[0m, (esc)
  ~~~   or use a GUI like \x1b[1mgitk\x1b[0m to view the history. (esc)
  ~~~
  ~~~

Check that action has moved to the failed dir.

  $ ls "${WORK_D}/.actions/failed"
  action__*.gc_template.txt (glob)
  action__*.sh (glob)

Prep another action.

  $ "${CLN_EXE}" prepare 'printf "I like apple pie\n" > msg.txt' >/dev/null 2>&1

And move it to the ignored directory.

  $ "${CLN_EXE}" remove -method ignore
  ~~~
  ~~~
  ~~~ Hi!  I just removed a pending action for you.
  ~~~
  ~~~ * The action is now here '\x1b[1m.actions/ignored/action__*.sh\x1b[0m'. (esc) (glob)
  ~~~ * The template is now here '\x1b[1m.actions/ignored/action__*.gc_template.txt\x1b[0m'. (esc) (glob)
  ~~~
  ~~~ Now, there are a couple of things you should do.
  ~~~
  ~~~ * Check which files have changed:
  ~~~     $ \x1b[1mgit status\x1b[0m (esc)
  ~~~ * Add actions and commit templates (I know it says add--it means "track this change with git"):
  ~~~     $ \x1b[1mgit add .actions\x1b[0m (esc)
  ~~~ * After "adding" files, commit changes:
  ~~~     $ \x1b[1mgit commit\x1b[0m (esc)
  ~~~
  ~~~ You should explain in the commit message why you needed to remove
  ~~~ the action.  It will help you later when you're going through the
  ~~~ git logs!
  ~~~
  ~~~ After that you are good to go!
  ~~~
  ~~~ * You can now check the logs with \x1b[1mgit log\x1b[0m, (esc)
  ~~~   or use a GUI like \x1b[1mgitk\x1b[0m to view the history. (esc)
  ~~~
  ~~~

Check that action has moved.

  $ ls "${WORK_D}/.actions/ignored"
  action__*.gc_template.txt (glob)
  action__*.sh (glob)

Clean up.

  $ cd ${TESTDIR}; rm -r "${WORK_D}"
