---
description: In this tutorial, we show how to manage your computational lab notebook by using the cln command line to correct actions that failed.
---

# Correcting failed actions

In this tutorial, we will see how to handle actions that fail.

## Set up project

First, let's set up a new project.

```
$ mkdir silly_project && cd silly_project
$ cln init 'Silly Project'
```

## Prepare failing action

Now, let's set up an action that I know will fail.

```
$ cln prepare 'printfff "hello, world\n" > hello.txt'
$ tree -a -I .git
.
├── .actions
│   ├── completed
│   ├── failed
│   ├── ignored
│   └── pending
│       ├── action__431785600__2021-04-09_18:03:59.gc_template.txt
│       └── action__431785600__2021-04-09_18:03:59.sh
└── README.md
```

See how the action is `pending`?  And now, we can try and run the
action.

## Try to run the action

```
$ cln run
.actions/pending/action__60687951__2021-04-09_17:49:45.sh: line 1: printfff: command not found
ERROR (code 127) when running action '.actions/pending/action__60687951__2021-04-09_17:49:45.sh'
$ tree -a -I .git
.
├── .actions
│   ├── completed
│   ├── failed
│   ├── ignored
│   └── pending
│       ├── action__431785600__2021-04-09_18:03:59.gc_template.txt
│       └── action__431785600__2021-04-09_18:03:59.sh
├── hello.txt
└── README.md
```

As you see, the action failed.  (You can check the error code with
`echo $?`.)  Whoops! We wrote `printfff` instead of `printf`.  That
should be easy enough to fix.

One thing to keep in mind is that even though the command failed, the
`hello.txt` file was still created.  It is just empty.  That's because
the action we tried to run had the `>` (redirect) in there.

Also, notice how the action that failed is still sitting there in the
`pending` directory.

## Remove failing action

Before we can prepare a new action, we have to remove the current
pending action.  The `cln` program will only let you have one pending
action at a time, so we have to remove the failed action before
creating a new one.

To do that, use the `cln remove` command.  Here is the help screen for
that command.

```
$ cln help remove
Remove a pending action

  cln remove

=== info ===

If there is a pending action, this will 'remove' it.

There are three ways to remove pending actions: 1) delete them, 2)
move them into the ignored directory, and 3) move them into the failed
directory.  Use whichever one makes the most sense for why you need to
remove them.

For more info, see https://mooreryan.github.io/cln_docs/

=== flags ===

  -method string  How to 'remove'? (delete, fail, or ignore)
  [-help]         print this help text and exit
                  (alias: -?)
```

As you can see, you need to supply a `method`.  Since the action is
bad (i.e., we tried to run it and it failed), let's use the `-method
fail` option.  You could also use `-method delete`, but I think it is
nice to keep actions that failed, as they may prove useful in the
future when you return to this project in a couple of months.

```
$ cln remove -method fail
$ tree -a -I .git
.
├── .actions
│   ├── completed
│   ├── failed
│   │   ├── action__431785600__2021-04-09_18:03:59.gc_template.txt
│   │   └── action__431785600__2021-04-09_18:03:59.sh
│   ├── ignored
│   └── pending
├── hello.txt
└── README.md
```

The failing action (and its git commit template) are moved into
the `<project_root>/.actions/failed` directory.

Notice how that `hello.txt` file is still there?

## Track the failed action

Okay, now is a good time to check the status of the git repository.

```
$ git status
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	.actions/
	hello.txt

nothing added to commit but untracked files present (use "git add" to track)
```

Since this is actually the first time we are commiting something other
than the initial commit when we ran `cln init`, it shows the whole
`.actions` directory as `untracked`.  That's fine.  We can just add
the whole thing.

```
$ git add .actions/
$ git status
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   .actions/failed/action__431785600__2021-04-09_18:03:59.gc_template.txt
	new file:   .actions/failed/action__431785600__2021-04-09_18:03:59.sh

Untracked files:
  (use "git add <file>..." to include in what will be committed)
	hello.txt
```

Note that I didn't add the `hello.txt` file.  See how it is still
marked as untracked.  That's because it is just empty and not what we
wanted anyway, so I won't bother checking it in to the git repo.

Now, we can commit these changes with a message describing why we are
putting this action in the failed actions directory:

```
$ git commit -m "Track a failed 'printf' action

I tried to run the printf action, but I accidentally typed 'printfff'
instead of 'printf', so the action failed."
```

## Prepare a new action

And now we can make a new action that will (hopefully) succeed.

```
$ cln prepare 'printf "hello, world\n" > hello.txt'
$ cln run
$ tree -a -I .git
.
├── .actions
│   ├── completed
│   │   ├── action__169733033__2021-04-09_17:59:33.gc_template.txt
│   │   └── action__169733033__2021-04-09_17:59:33.sh
│   ├── failed
│   │   ├── action__60687951__2021-04-09_17:49:45.gc_template.txt
│   │   └── action__60687951__2021-04-09_17:49:45.sh
│   ├── ignored
│   └── pending
├── hello.txt
└── README.md
```

And check the contents of `hello.txt`.

```
$ cat hello.txt
hello, world
```

## Track changes

That's what we want.  So now let's check the git status again.

```
$ git status
On branch master
Untracked files:
  (use "git add <file>..." to include in what will be committed)
	.actions/completed/
	hello.txt

nothing added to commit but untracked files present (use "git add" to track)
```

Since the `hello.txt` file is small, we can track it with `git` and
not bother with `git-annex`.  If it was very large, we would want to
use `git-annex add` rather than `git add`.

Add (aka track) all new changes.

```
$ git add .
$ git status
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   .actions/completed/action__169733033__2021-04-09_18:30:11.gc_template.txt
	new file:   .actions/completed/action__169733033__2021-04-09_18:30:11.sh
	new file:   hello.txt
```

Now we are ready for the commit.

```
$ git commit -t
```

Now you should see a text editor pop up with something like this:

```
Run the 'printf' action

== Details ==
This action creates a hello world file using the printf command.

== Command(s) ==
/usr/bin/printf "hello, world\n" > hello.txt

== Action file ==
action__169733033__2021-04-09_18:30:11.sh

# Please enter the commit message for your changes. Lines starting
# with '#' will be ignored, and an empty message aborts the commit.
#
# On branch master
# Changes to be committed:
#	new file:   .actions/completed/action__169733033__2021-04-09_18:30:11.gc_template.txt
#	new file:   .actions/completed/action__169733033__2021-04-09_18:30:11.sh
#	new file:   hello.txt
#
```

Note that I changed the all caps lines to what you see above.  When
you finish editing the message, save and exit your editor to commit
the changes with that message.

## Wrap up

In this tutorial, we saw how to deal with actions that fail.  Here's
what we did:

* Prepare an action.
* Try to run it, but it fails.
* Remove the action with `cln remove -method fail`.
* Commit failed action to the git repo.
* Make a new action.
* Try to run it and it succeeds.
* Commit successful action and changes to the git repo.
