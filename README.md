# Computational Lab Notebooks

[![Build and test](https://github.com/mooreryan/computational_lab_notebooks/actions/workflows/build_and_test.yml/badge.svg)](https://github.com/mooreryan/computational_lab_notebooks/actions/workflows/build_and_test.yml)

CLI app to help you manage your computational lab notebook using git
and git annex.

It's inspired by [Rails ActiveRecord
migrations](https://guides.rubyonrails.org/active_record_migrations.html#running-migrations),
in that it helps you prepare, run, and commit actions.

## Install

I haven't uploaded binaries yet.  In the meantime, you can install
from source.

### Install git and git annex

Git and git annex are required.  You can install them with your
package manager, e.g.: `sudo apt-get install git git-annex`.

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

### Install from source

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

### Set up bash completion (optional)

If you want bash completions and are running Linux, run

```sh
sudo make install_bash_completion
```

This installs the bash completions to `/etc/bash_completion.d`.  To
activate bash completions for your current shell session, source the
file:

```sh
. utils/cln_bash_completion.s
```

#### No sudo or custom completion directory

If you don't have `sudo` or you want to install them somewhere else,
you can set the `BASH_COMPLETION_D` environment vabiable like this:

```sh
make BASH_COMPLETION_D=${HOME}/Desktop/silly_completions install_bash_completion
```

That would install them to `${HOME}/Desktop/silly_completions`.

### Run the tests (optional)

It's always nice to run tests locally.  Unfortunately, you need to set
up `cram` yourself to run the tests.

#### Set up cram

If you want to run the tests, you need to [install
cram](https://bitheap.org/cram/).

Cram depends on Python.  If you need to install python, you could do
something like this:

```sh
sudo apt-get update && \
     sudo apt-get install -y wget \
                             python3 \
                             python3-distutils && \
     sudo ln -s $(which python3) /usr/bin/python
```

I am no Python expert, so you may want to [read a
guide](https://wiki.python.org/moin/BeginnersGuide/Download) on how to
install.  The above command was enough for me to get Python installed
for Cram on a clean Docker image though.

Then download and install cram:

```sh
cd ~/Downloads
wget https://bitheap.org/cram/cram-0.6.tar.gz
tar zxvf cram-0.6.tar.gz
cd cram-0.6
make install
```

Alternatively, you may already have python installed and want to
install cram with pip: `pip install cram`.

#### Run tests

Now you can run the tests:

```sh
make test
```

Note that you may still need to setup the opam environment if you
haven't reopended a new shell:

```sh
eval $(opam env) && make test_all
```

### Uninstall

If you installed with the above procedure, you can run

```sh
make clean && make uninstall
```

to uninstall the program.  If you also installed the bash completions,
don't forget to delete those as well.

## Usage

Check the help screen for usage info:

```
cln help
```

## Examples

For some usage examples, see the cram tests in `<project
root>/tests/cram`.  The `*.t` files are cram tests.  They look a bit
weird at first but the walk through different scenarios of using the
`cln` CLI app.  Also, they are guaranteed to be up to date with
whatever version of the code you're running since they are basically
integration tests!

## License

Licensed under the Apache License, Version 2.0 or the MIT license, at
your option. This program may not be copied, modified, or distributed
except according to those terms.
