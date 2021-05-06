---
description: Instructions for installing cln, the command line app that helps you set up and manage computational lab notebooks using git and git-annex.
---

# Installation

The `cln` app requires you have
[git](https://git-scm.com/book/en/v2/Getting-Started-Installing-Git)
and [git-annex](https://git-annex.branchable.com/install/) installed
and set-up on your computer.

Additionally, if you want to build the app from source, you will need
OCaml, opam, and dune.

## Install git and git-annex

[Git](https://git-scm.com/) and
[git-annex](https://git-annex.branchable.com/) are required.  See the
links for installation instructions.

If you want to install them from source or in an specific way, check
out the sites linked above.  If not, you can just use the package
manager.

### Linux

You can install them with your package manager, e.g.: `sudo apt-get
install git git-annex`.

### macOS

You can install them with Homebrew: `brew install git git-annex`.

## Install a pre-compiled binary

This is the easiest way to install the `cln` program.

* Go to the [releases page on
  GitHub](https://github.com/mooreryan/computational_lab_notebooks/releases/).
* Download the zip file for either macOS or Linux, depending on your
  OS.
* Unzip the file.
* It should have one file `cln`.  Move this to somewhere on your PATH,
  e.g., `/usr/local/bin` or `$HOME/.local/bin`.
* If all goes well, you should be able to run the `cln` program.  Try
  it out with `cln help`.

## Install from source

Installing from source isn't *too* hard.  The problem is that you
probably don't already have OCaml installed on your computer, so you
will have to install that first.

*Note that you don't actually have to install from source.  You can
use the [precompiled
binaries](https://github.com/mooreryan/computational_lab_notebooks/releases/)
instead.

### Set up OCaml

* First [install OCaml](https://dev.realworldocaml.org/install.html).
  That guide is long, but you just need to do the parts for setting up
  and configuring opam.
  * [Install
    opam](http://opam.ocaml.org/doc/Install.html#Using-your-distribution-39-s-package-system)
    using your package manager.
  * Initialize opam with `opam init` command.
  * You may want to install the latest OCaml compiler: `opam switch
    create 4.12.0 && eval $(opam env)`.
* Next, install the required libraries: `opam install dune core
  jingoo`.  Note that you may need to run `eval $(opam env)` again
  after this.

### Get the cln source code

Download the source code (assuming you have git installed):

```sh
git clone https://github.com/mooreryan/computational_lab_notebooks.git
cd computational_lab_notebooks.git
make && make install
```

Check that the `cln` program is now on your path.

```sh
which cln # should print out something like this: /home/ryan/.opam/4.12.0/bin/cln
```

## Set up bash completion (optional)

To activate bash completions for your current shell session, source
the file:

```sh
. utils/cln_bash_completion.s
```

If you want to install the bash completions (e.g., for future
sessions), run:

```sh
sudo make install_bash_completion
```

This installs the bash completions to `/etc/bash_completion.d`.

### No sudo or custom completion directory

If you don't have `sudo` or you want to install the bash completions
somewhere else, you can set the `BASH_COMPLETION_D` environment
vabiable like this:

```sh
make BASH_COMPLETION_D=${HOME}/Desktop/silly_completions install_bash_completion
```

That would install them to `${HOME}/Desktop/silly_completions`.  Of
course, you would need to ensure that they are automatically sourced
in that directory!


## Run tests (optional)

It's always nice to run tests locally.  If you have a working OCaml
and Dune installation (see above), you can use `make` to run the
tests.

```sh
make test
```

Note that, if you installed OCaml for the first time, and you haven't
closed and re-opended your shell, you may still need to setup the opam
environment:

```sh
eval $(opam env) && make test
```

## Uninstall

### If you installed from source

If you installed with the [above
procedure](#install-from-source), you can run

```sh
make uninstall && make clean
```

to uninstall the program.  If you also installed the bash completions,
don't forget to delete those as well.

### If you installed a precompiled binary

All you have to do is remove the binary!

### If you installed bash completions

Just remove the bash completions file.
