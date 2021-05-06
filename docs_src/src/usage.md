---
description: Instructions for using cln, the command line app that helps you set up and manage computational lab notebooks using git and git-annex.
---

# Usage

The four main commands are

* [`cln init`](#initialize-a-new-project) -- initialize a new project
* [`cln prepare`](#prepare-an-action) -- prepare an action
* [`cln run`](#run-an-action) -- run an action
* [`cln remove`](#remove-an-action) -- remove an action

Check the help screen for usage info:

```
$ cln help
Computational Lab Notebooks

  cln SUBCOMMAND

CLI to help you manage a lab notbook with git and git-annex.

=== subcommands ===

  init     Initialize a new project
  prepare  Prepare an action
  remove   Remove a pending action
  run      Run an action
  version  print version information
  help     explain a given subcommand (perhaps recursively)
```

## Initialize a new project

To initialize a new project/lab notebook use `cln init`.  The `cln`
app is a wrapper on `git` and `git-annex`, so your project lives in a
certain directory.  That directory is the one in which you run the
`cln init` command!

There is nothing magical about the `cln init` command.  It sets up the
required directories, makes a `README.md` file, and then sets up a new
`git` and `git-annex` repository.

After you run `cln init`, you are ready to start getting some real
work done!

### Usage

To view the usage screen, run `cln help init` or `cln init -help`.

```
$ cln help init
Initialize a new project

  cln init PROJECT_NAME

=== info ===

Initialize a new computational lab notebook project using git and
git-annex.

For more info, see https://mooreryan.github.io/cln_docs/

=== flags ===

  [-help]  print this help text and exit
           (alias: -?)
```

### Example

First make a new directory and `cd` into it.

```
$ mkdir my_project && cd my_project
```

Then initialize a new project called `My Project`.

```
$ cln init 'My Project'
```

Notice how I put the `My Project` bit inside single quote characters
(`'`)?  If your project name has spaces, you need to remember to quote
it!

### Notes

* If you run `cln init` in a directory that already has a git
  repository, you will get an error.

## Prepare an action

To prepare an action or command to run, use the `cln prepare` command.

This creates a new action file (i.e., bash script) and a git commit
template in the `<project_root>/.actions/pending` directory.

When I say "action", I just mean, something (e.g., a shell script)
that will change the state of the repository (aka your lab notebook).
The reason we formalize these things as actions is that it makes it a
lot easier to figure out what happened in your project/repository a
couple of months down the line when you come back to it.

### Usage

To vier the usage screen, run `cln help prepare` or `cln prepare
-help`.

```
$ cln help prepare
Prepare an action

  cln prepare ACTION

=== info ===

Generates an action file and a git commit template in the
'<project_root>/.actions/pending' directory.

For more info, see https://mooreryan.github.io/cln_docs/

=== flags ===

  [-help]  print this help text and exit
           (alias: -?)

```

### Example

Prepare a shell command to run:

```
$ cln prepare 'echo "hello, world" > hello.txt'
```

Rather than running `echo "hello, world" > hello.txt` yourself,
"preparing" the command sets it up so that you have a way to run the
command that makes it easier to remember what you did a few
months/years down the line.

#### What files were created?

##### Action file

You have the action file (aka bash script):

```
$ cat .actions/pending/action__262765981__2021-04-09_14:54:48.sh
/usr/bin/echo "hello, world" > hello.txt
```

The first weird number in the file name is a hash code representing
the contents of the file.  The second is the date and time in which
you prepared the command.

##### Commit template

And you have the git commit template.  Git [commit
templates](https://git-scm.com/docs/git-commit#Documentation/git-commit.txt---templateltfilegt)
are a nice way to help you write good commit messages with as little
annoyance as possible.

```
$ cat .actions/pending/action__262765981__2021-04-09_14:54:48.gc_template.txt
PUT COMMIT MSG HERE.

== Details ==
PUT DETAILS HERE.

== Command(s) ==
/usr/bin/echo "hello, world" > hello.txt

== Action file ==
action__262765981__2021-04-09_14:54:48.sh
```

Notice how the prepared action and the action file are automatically
included in the commit template?  This is really helpful for when
you're going back searching through the commit logs.  It will give you
context of the exact command that was run connected with the exact
changes it produced in any of the files included in your repository.

After you run the action, add the changes to git and then go to
actually commit the changes, you can use the commit template like
this:

```
$ git commit -t .actions/pending/action__262765981__2021-04-09_14:54:48.gc_template.txt
```

This will open up a text editor with the contents of that file.  Then
you just have to edit the summary message and the details.  For the
summary, just put a short < 50 character explanation of what you did.
For the details, try and put as much info and context as you will need
to figure out what you did and why you did it.  Basically, you should
put the sort of things here that you would be putting in your lab
notebook anyway.

### Notes

If you try and prepare an action when there is already a pending
action, you will get an error.  It's set up this way to encourage you
to set up a single action, run it (which then changes the state of
your repository, then commit those changes to the repository.  So it's
like 1 action <=> 1 commit.

## Run an action

To run an action, use the `cln run` command.

This will look for a valid pending action, and if it finds one, runs
it with `bash`.  If it succeeds, then the program will also move the
action into the `<project_root>/.actions/completed` directory.

* You will get an error if there are no pending actions.
* If there are more than one pending action, you will also get an
  error.
  * The `cln prepare` command won't let you make more than one pending
    action.
  * But even if you make an extra "by-hand" with the format exactly
    correct, the `cln run` command still won't let you run it if there
    are more than one.

### Dry run

To do a "dry run", i.e., to have the `cln prepare` program just tell
you what it will do without actually running any actions, you can use
the `-dry-run` flag.  Here is an example:

```
$ cln run -dry-run
```

You will see some useful output.  Check it out and make sure it looks
good.  If so, then you can run the action.

While the `-dry-run` is totally optional, I recommend that you do a
dry run before running the action so you can check that you haven't
made any obvious mistakes!

### A note on exit codes

To determine wether an action has failed or succeeded, we check the exit codes.

* Exit code of `0` means success.
* Any other exit code means failure.

Let's say that you prepared an action to run some bash script that you
have written like this:

```sh
printf "Starting script!\n"

## This command will fail.
cat this_file_doesnt_exist.txt > new_file.txt

## But the script will keep going and run this, which will succeed.
printf "All done!\n"
```

If you ran this at the command line with bash, you would get this:

```
$ bash silly.sh
Starting script!
cat: this_file_doesnt_exist.txt: No such file or directory
All done!
```

Do you think it "succeeded"?  Let's check the exit code.

```
$ echo $?
0
```

According to the exit code, yes, the script as a whole succeeded.  But
if you check the contents of `new_file.txt` you will see that it is
empty, which is probably not what you wanted!  So what happened is
that an intermediate command failed, but given the way the script was
written, the script as a whole succeeded.

#### How to fix it

This is something you will want to watch out for.  If this were run as
an action by `cln run`, the `cln` program would consider this program
a success and move the action into the `completed` directory.

If you have scripts like this that run lots of commands, you should
consider breaking them up.  That way you stick to the one action, one
commit principal mentioned above.

#### If you really want a multi-command bash script

In some cases, you may need more than one command, e.g., when
something only makes sense if something succeeds first.  In that case,
you can join the commands with `&&`.  Let's try that on the previous
example.

```sh
printf "Starting script!\n" && \
  cat this_file_doesnt_exist.txt > new_file.txt && \
  printf "All done!\n"
```

And run that.

```
$ bash silly2.sh
Starting script!
cat: this_file_doesnt_exist.txt: No such file or directory
```

See how the last `printf` command was not run?  Let's check the exit
code again.

```
$ echo $?
1
```

That's a failing exit code.  So, the `cln run` program would consider
that script to have failed.

## Remove an action

Sometimes you need to remove pending actions:

* You made a mistake when prepping the action.
* You don't need that action anymore.
* There was an error when running the action.
* Whatever!

The point is that you sometimes will want to delete actions!  The way
that the `cln` program currently works is that you can only ever have
one pending action at a time.  So if you have messed something up and
need to get rid of the action, you will need to remove it.  To do
this, we use the `cln remove` program.

### Deleting, failing, or ignoring actions

There are three ways to "remove" a pending action:

* Deleting it
* Marking it as "failed" (aka failing the action)
* Marking it as "ignored" (aka ignoring the action)

Of these three only deleting truly deletes the action data.  (And even
then, if you've already checked it into your git repository you will
still be able to get it back.)

"Failing" an action means moving the action (and its associated git
commit template) out of the `.actions/pending` directory and into the
`.actions/failed` directory.

"Ignoring" an action is similar to "failing" an action except that the
pending action is moved to the `.actions/ignored` directory rather
than the `.actions/failed` directory.

The reason for this distinction is to help you when you're going back
through your history and commit logs.  I.e., it will give you more
context as to why a pending action was no longer necessary.

### Specifying the method

You specify the method you want to use with the `-method` flag like
this

* Delete: `cln remove -method delete`
* Fail: `cln remove -method fail`
* Ignore: `cln remove -method ignore`

### Saving the results in the git repo

After you run the `cln remove` command you will see some output
suggesting how to proceed.  You may see something like this:

```
~~~ * Check which files have changed:
~~~     $ git status
~~~ * Add actions and commit templates (I know it says add--it means "track this change with git"):
~~~     $ git add .actions
~~~ * After "adding" files, commit changes:
~~~     $ git commit
```

As you can see, you still need to let `git` know that you have moved
the actions around and commit the changes.

### Manually removing actions

Like many of the `cln` commands, you *could* just do this "by-hand".
Currently, the `cln remove` command is a pretty thin wrapper around
what you would probably do by hand, but it does give you some nice
messages on what you may want to do next and it does some sanity
checking on your pending actions to make sure nothing has gotten crazy
in the meantime.
