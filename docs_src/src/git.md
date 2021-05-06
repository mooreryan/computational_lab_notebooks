---
description:  Git is a powerful tool for tracking changes in a repository.  The cln app uses git and git-annex to help you manage your computational lab notebook.  This tutorial should be enough info to help you get started with git.
---

# Just Enough Git

The `cln` app helps you manage your computational lab notebook with
[git](https://git-scm.com/) and
[git-annex](https://git-annex.branchable.com/).  While you still need
to know some things about git and git-annex, you don't need *too* much
-- as long as you're comfortable with some of the fundamentals, you
should be good.

## Everyday Commands

Let's go through some [everyday git
commands](https://git-scm.com/docs/everyday).

```
/tmp/example$ git --version
git version 2.27.0
```

### How to get help

To get a basic overview of command git commands:

```
$ git help

...prints out the help screen...
```

For more detailed help, use

```
$ git help -a

...lots and lots of commands...
```

To get help with a specific commands do something like this:

```
$ git help add

...shows help page for git-add

$ git help checkout

...shows help page for git-checkout
```

To get help with some of the most common git commands, run this:

```
$ git help everyday

...shows useful commands...
```

## Basic git workflow

Let's run through a basic example git workflow.  In this example, I
will make a new project (git repository), make a `README.md`, make
some fake reads in a fasta file, do some silly "quality control".

Lines that start with `$` are commands that I ran.

Initialize a new git repository.

```
$ git init
Initialized empty Git repository in /tmp/example/.git/
```

Make a README file.

```
$ printf "# My Cool Project
>
> This willl be a really fun project
> " > README.md
```


Add readme file contents to the "index".

```
$ git add README.md
```

Commit changes with message.

```
$ git commit -m "Initial commit"
[master (root-commit) d93d073] Initial commit
 1 file changed, 3 insertions(+)
 create mode 100644 README.md
```

Create and switch to a new branch called make-seqs.

```
$ git checkout -b make-seqs
Switched to a new branch 'make-seqs'
```

Make a fasta file.

```
$ printf ">seq1
> ACTG
> >seq2
> actg
> " > seqs.fa
```


Add the fasta file to the index.

```
$ git add seqs.fa
```

Commit the changes with a message.

```
$ git commit -m "Make a fake seqs file"
[make-seqs 0748c17] Make a fake seqs file
 1 file changed, 4 insertions(+)
 create mode 100644 seqs.fa
```

Switch back to the master branch.

```
$ git checkout master
Switched to branch 'master'
```

Merge the changes in the make-seqs branch into the master branch.

```
$ git merge make-seqs
Updating d93d073..0748c17
Fast-forward
 seqs.fa | 4 ++++
 1 file changed, 4 insertions(+)
 create mode 100644 seqs.fa
```

Delete the make-seqs branch.

```
$ git branch -d make-seqs
Deleted branch make-seqs (was 0748c17).
```

Create and switch to a new branch called qc.

```
$ git checkout -b qc
Switched to a new branch 'qc'
```

Do some (fake) "quality control".

```
$ tr "a" "N" < seqs.fa > seqs.qc.fa
```

Add the changes/new file to the index.

```
$ git add seqs.qc.fa
```

Commit the changes with the given message.

```
$ git commit -m "Run read QC"
[qc 6a8f070] Run read QC
 1 file changed, 4 insertions(+)
 create mode 100644 seqs.qc.fa
```

Check the log to see what we have done.

```
$ git log --pretty=oneline
6a8f070741e083de38cee9498123c984ee33d514 (HEAD -> qc) Run read QC
0748c17a80587f1e9f5832a1966c6d1ddb9960de (master) Make a fake seqs file
d93d0735c7b05c5d69e80c5c68926e12be1744d8 Initial commit
```

Switch back to the master branch.

```
$ git checkout master
Switched to branch 'master'
```

Okay, that quality control wasn't very good, just delete the qc branch
like it never happened.

```
$ git branch -D qc
Deleted branch qc (was 6a8f070).
```

Check the log...the "quality control" step is gone!

```
$ git log --pretty=oneline
0748c17a80587f1e9f5832a1966c6d1ddb9960de (HEAD -> master) Make a fake seqs file
d93d0735c7b05c5d69e80c5c68926e12be1744d8 Initial commit
```

See...just readme and sequences.

```
$ ls
README.md  seqs.fa
```

It's the file we made.

```
$ cat seqs.fa
>seq1
ACTG
>seq2
actg
```

## What is an "index"?

Here is what the `git-add` help file says about the "index":

> The "index" holds a snapshot of the content of the working tree, and
> it is this snapshot that is taken as the contents of the next
> commit. Thus after making any changes to the working tree, and before
> running the commit command, you must use the add command to add any
> new or modified files to the index.

## git-add followed by more edits

If you run `git add some_file.txt`, then change the contents of
`some_file.txt` again *before* commiting the changes, those new
changes will not be reflected in the repository unless you run `git
add some_file.txt` again before commiting.  Here is an example of what
I mean:

Edit the seqs file with nano.

```
$ nano seqs.fa
```

Show the difference from last commit.  I edited the first sequence
name.  Lines that change have a `-` indicated the old version and a
`+` indicated the new change.

```
$ git diff seqs.fa
diff --git a/seqs.fa b/seqs.fa
index 60129d5..53d21e0 100644
--- a/seqs.fa
+++ b/seqs.fa
@@ -1,4 +1,4 @@
->seq1
+>seq1_best_sequence
 ACTG
 >seq2
 actg
```

Add the changes to the index.

```
$ git add seqs.fa
```

Check the status.  The changes are now staged for the commit.

```
$ git status
On branch master
Changes to be committed:
  (use "git restore --staged <file>..." to unstage)
	modified:   seqs.fa
```

Edit the file again.

```
$ nano seqs.fa
```

Show the differences again.  I edited the second sequence name.

```
$ git diff seqs.fa
diff --git a/seqs.fa b/seqs.fa
index 53d21e0..c89e2ff 100644
--- a/seqs.fa
+++ b/seqs.fa
@@ -1,4 +1,4 @@
 >seq1_best_sequence
 ACTG
->seq2
+>seq2_2nd_best
 actg
```

Commit the staged changes (still just the first name change!)

```
$ git commit -m "Edit the seqs file"
[master c5c5681] Edit the seqs file
 1 file changed, 1 insertion(+), 1 deletion(-)
```


Check status.  See how there are still changes not staged for commit?
That's because `git add` stages changes at the time you ran `git-add`.

```
$ git status
On branch master
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   seqs.fa

no changes added to commit (use "git add" and/or "git commit -a")
```


The changes are still there in the file though.

```
$ cat seqs.fa
>seq1_best_sequence
ACTG
>seq2_2nd_best
actg
```

Check the difference.  See how the 2nd header is different?

```
$ git diff seqs.fa
diff --git a/seqs.fa b/seqs.fa
index 53d21e0..c89e2ff 100644
--- a/seqs.fa
+++ b/seqs.fa
@@ -1,4 +1,4 @@
 >seq1_best_sequence
 ACTG
->seq2
+>seq2_2nd_best
 actg
```

Add the current changes to the index.

```
$ git add seqs.fa
```

Commit the changes.

```
$ git commit -m "Change 2nd header"
[master 9454d4e] Change 2nd header
 1 file changed, 1 insertion(+), 1 deletion(-)
```

Check the status...the working tree is clean, all changes have been
commited.

```
$ git status
On branch master
nothing to commit, working tree clean
```

## Git Branches

Git has branches to help you keep work isolated.  You generally have a
main branch called `master` or `main`.  This is the "main" branch in
the sense that it is the main access point for your repository or
project.

You can do all your work in the main branch, but if you make mistakes
and need to roll back any changes, it can be harder than if you do all
of your work in a separate branch (i.e., a "working" branch).

Let's see a little example to show you what I mean.

### Create a new git repo

Make a new git repository, add and commit an example text file.

```
$ mkdir example && cd example
$ git init
$ printf "hello, world\n" > hello.txt
$ git add . && git commit -m "Initial commit"
```

Check the current branch.

```
$ git branch
* master
```

See how we are on the master branch to start with?  Now, let's create
and switch to a new branch.

### Create a new branch and do some work


```
$ git checkout -b edit-hello
Switched to a new branch 'edit-hello'
```

And now when we run `git branch` you can see we are on a different
branch.

```
$ git branch
* edit-hello
  master
```

#### Edit the file in the work branch

Now we will edit the `hello.txt` file in the new `edit-hello` branch
we just created.

```
$ sed -i 's/l/L/g' hello.txt
```

That's the [sed](https://www.gnu.org/software/sed/manual/sed.html)
command.  If you haven't seen it, it is a stream editor.  All that
command does is change every `l` to a `L` in the file.

Now check the status of the repository.

```
$ git status
On branch edit-hello
Changes not staged for commit:
  (use "git add <file>..." to update what will be committed)
  (use "git restore <file>..." to discard changes in working directory)
	modified:   hello.txt

no changes added to commit (use "git add" and/or "git commit -a")
```

It says that the `hello.txt` file has changed.  Let's check the
changes now.

```
$ git diff hello.txt
diff --git a/hello.txt b/hello.txt
index 4b5fa63..09d7e19 100644
--- a/hello.txt
+++ b/hello.txt
@@ -1 +1 @@
-hello, world
+heLLo, worLd
```

We can see that `hello, world` is now `heLLo, worLd`.  That's what we
wanted so now we can commit the changes.

#### Commit the changes in the work branch

```
$ git add hello.txt
$ git commit -m "Swich lowercase 'l' to uppercase 'L'"
[edit-hello 27e542d] Swich lowercase 'l' to uppercase 'L'
 1 file changed, 1 insertion(+), 1 deletion(-)
```

Just double check that the git repository is clean now.

```
$ git status
On branch edit-hello
nothing to commit, working tree clean
```

### How has our repository changed

So now we've done some work on the `edit-hello` branch, let's switch
back to the `master` branch and see check the state of the repository.

```
$ git checkout master
Switched to branch 'master'
$ git status
On branch master
nothing to commit, working tree clean
$ cat hello.txt
hello, world
```

Whoa!  The `hello.txt` file is the same as it was before we switched
branches and did all those changes.  Let's check the log.

```
git log --pretty=oneline
8a5b9042705aff008dc396b385a3f03200e79647 (HEAD -> master) Initial commit
```

See how that last commit isn't even listed?  Let's go back to the
`edit-hello` branch and check the log there.

```
$ git checkout edit-hello
Switched to branch 'edit-hello'
$ git log --pretty=oneline
27e542d2192c3b1807f14b2460118045d549d7f5 (HEAD -> edit-hello) Swich lowercase 'l' to uppercase 'L'
8a5b9042705aff008dc396b385a3f03200e79647 (master) Initial commit
```

Okay, both commits are still there.  Notice how the commit at the top
says `(HEAD -> edit-hello)` whereas the first commit says `(master)`?
This is telling you that the commits are specific to certain branches.
Just to reinforce this, we will switch back to `master` and look at
the logs again.

```
$ git checkout master
Switched to branch 'master'
$ git log --pretty=oneline
8a5b9042705aff008dc396b385a3f03200e79647 (HEAD -> master) Initial commit
```

Back to one commit with `(HEAD -> master)`.  And one more time, back
to `edit-hello` branch.

```
$ git checkout edit-hello
Switched to branch 'edit-hello'
$ git log --pretty=oneline
27e542d2192c3b1807f14b2460118045d549d7f5 (HEAD -> edit-hello) Swich lowercase 'l' to uppercase 'L'
8a5b9042705aff008dc396b385a3f03200e79647 (master) Initial commit
```

### What to do with the changes?

Now we have two options.

* I like the changes in the `edit-hello` branch and want to make them
  part of the `master` branch.
* I don't like the changes in the `edit-hello` branch and want to
  forget about them.

#### Keep the changes in the work branch

For the first, I need to merge the changes in the `edit-hello` branch
into the `master` branch.  Let's do that now.

```
$ git branch
* edit-hello
  master
$ git checkout master
Switched to branch 'master'
$ git branch
  edit-hello
* master
$ git merge edit-hello
Updating 8a5b904..27e542d
Fast-forward
 hello.txt | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)
$ git status
On branch master
nothing to commit, working tree clean
$ git log --pretty=oneline
27e542d2192c3b1807f14b2460118045d549d7f5 (HEAD -> master, edit-hello) Swich lowercase 'l' to uppercase 'L'
8a5b9042705aff008dc396b385a3f03200e79647 Initial commit
$ cat hello.txt
heLLo, worLd
```

See how the second commit is now in the git log and see how the
`hello.txt` file has the changes?  Since the changes are fully merged,
we can safely delete the `edit-hello` branch.

```
$ git branch -d edit-hello
Deleted branch edit-hello (was 27e542d).
$ git branch
* master
```

And now the `edit-hello` branch is gone.

#### Get rid of the changes in the work branch

What about the second option.  Let's say we don't really like the
changes of the `edit-hello` branch, and we just want to get rid of
them.  In that case we delete the branch *without* first merging the
changes.

*(Note that the hash values have changed.  That's because, for this
tutorial, I just deleted the whole repository and started over rather
than bother rolling back the changes like I would do in a real
repository.)*

First, make sure you are on the `master` branch.

```
$ git checkout master
Already on 'master'
$ git branch
  edit-hello
* master
```

Then delete the `edit-hello` branch.

```
$ git branch -d edit-hello
error: The branch 'edit-hello' is not fully merged.
If you are sure you want to delete it, run 'git branch -D edit-hello'.
```

See the error you got?  This is because there are changes present in
the `edit-hello` working branch that are not currently part of the
`master` branch.  So if you were to delete the `edit-hello` branch
now, you would lose those changes with no way to get them back.  Since
this is actually what we want to do, we will follow the instructions
on the screen and use the `-D` flag instead of `-d` to force deletion
of the `edit-hello` branch.

```
$ git branch -D edit-hello
Deleted branch edit-hello (was cc722a5).
$ git branch
* master
$ git log --pretty=oneline
f15b723b204deb59b1f23577439ec58d917b2269 (HEAD -> master) Initial commit
$ cat hello.txt
hello, world
```

As you see, we are back to the initial commit as though all of the
work on the `edit-hello` branch never happened.

### Wrap up

Git branches are a powerful technique for isolating work in such a way
that you can test things out without worrying about "messing up" your
repository.  Then, when you've finished the task you're working on, if
it is good work, you can merge the changes into the `master` branch,
or, if it was bad, you can just delete the working branch without
applying any of the changes to the `master` branch.

### Notes

* Notice how I named the work branch with a short description of what
  I was actually planning to do?  This can be helpful if you have a
  lot of different branches.
