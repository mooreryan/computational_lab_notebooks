---
description: In this tutorial, we demonstrate how to ignore previously prepared actions using the cln command line app for computational lab notebooks.
---

# Ignoring actions

Sometimes you prepare an action, only to realize that for whatever
reason, you don't actually want to run the action.

For a more in depth tutorial about removing actions, see the [failed
actions](./correcting_failed_actions.md) tutorial.

## Set up

First, let's set everything up.

```
$ mkdir silly_project && cd silly_project
$ cln init 'Silly Project'
```

## Prepare an action

And prepare a bogus action.

```
$ cln prepare 'printfff "hello, world\n" > hello.txt'
```

## Dry run

Next, we do a dry run to see if everything looks okay.

```
$ cln run -dry-run
~~~
~~~
~~~ Hi!  I just previewed an action for you.
~~~
~~~ I plan to run this action file:
~~~   '.actions/pending/action__431785600__2021-04-09_21:38:08.sh'
~~~
~~~ It's contents are:
~~~
printfff "hello, world\n" > hello.txt

~~~
~~~ If that looks good, you can run the action:
~~~   $ cln run
~~~
~~~
```

Oh no!  Do you see in the preview how we made a mistake?  We typed
`printfff` instead of `printf`.  We know this won't work so we won't
even bother trying to run the action.  We will just remove it.

## Remove action with `delete` method

Since it is just a typing mistake, we don't really care about keeping
that action around, so we will use the `-method delete` option to just
straight delete the action.  First, here is what's in the `.actions`
directory.

```
$ tree .actions/
.actions/
├── completed
├── failed
├── ignored
└── pending
    ├── action__431785600__2021-04-09_21:38:08.gc_template.txt
    └── action__431785600__2021-04-09_21:38:08.sh
```

And now, remove the action.

```
$ cln remove -method delete
$ tree .actions
.actions/
├── completed
├── failed
├── ignored
└── pending
```

As you see the action and the commit template are gone.

## Remove action with `ignore` method

Sometimes you may need to remove an pending action, but you don't want
to just delete it outright.  In these cases, you can use the `-method
ignore` option.  Rather than delete the action, it will be moved from
the `pending` directory to the `ignored` directory.

Here is an example.

```
$ cln prepare 'printfff "hello, world\n" > hello.txt'
$ tree .actions/
.actions/
├── completed
├── failed
├── ignored
└── pending
    ├── action__431785600__2021-04-09_21:51:51.gc_template.txt
    └── action__431785600__2021-04-09_21:51:51.sh

$ cln remove -method ignore
~~~
~~~
~~~ Hi!  I just removed a pending action for you.
~~~
~~~ * The action is now here '.actions/ignored/action__431785600__2021-04-09_21:51:51.sh'.
~~~ * The template is now here '.actions/ignored/action__431785600__2021-04-09_21:51:51.gc_template.txt'.
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
$ tree .actions/
.actions/
├── completed
├── failed
├── ignored
│   ├── action__431785600__2021-04-09_21:51:51.gc_template.txt
│   └── action__431785600__2021-04-09_21:51:51.sh
└── pending
```

Since we used `ignore` rather than `delete`, we probably had a good
reason to keep the action around even though we didn't want to run it.
Maybe you typed in the wrong name for an output file, or decided that
some flags you passed to the program you wanted to run needing to be
changed.  Regargless, if you think it is worth keeping the action, you
should commit it to the lab notebook repository and put a descriptive
commit message.

*Note that the `cln remove` command even suggests that you do this!*

```
$ git status
$ git add .actions/
$ git status
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	new file:   .actions/ignored/action__431785600__2021-04-09_21:51:51.gc_template.txt
	new file:   .actions/ignored/action__431785600__2021-04-09_21:51:51.sh
$ git commit -m "Ignore the printf action

For some reason, I decided it was best not to run this. Blah blah blah
longish description so I remember why it is important and what I
learned."
```
