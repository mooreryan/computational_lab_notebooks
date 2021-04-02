# Computational Lab Notebooks

CLI app to help you manage your computational lab notebook using git and git annex.

It's inspired by [Rails ActiveRecord migrations](https://guides.rubyonrails.org/active_record_migrations.html#running-migrations), in that it helps you prepare, run, and commit actions.

## Install

I haven't uploaded binaries yet.  In the meantime, you can install from source.

### Install git and git annex

Git and git annex are required.  You can install them with your
package manager, e.g.: `sudo apt-get install git git-annex`.

### Set up OCaml

* First [install OCaml](https://dev.realworldocaml.org/install.html).
  That guide is long, but you just need to do the parts for setting up
  and configuring opam.
  * [Install opam](http://opam.ocaml.org/doc/Install.html#Using-your-distribution-39-s-package-system) using your package manager.
  * Initialize opam with `opam init` command.
  * You may want to install the latest OCaml compiler: `opam switch create 4.12.0 && eval $(opam env)`.
* Next, install the required libraries: `opam install dune core jingoo`.  Note that you may need to run `eval $(opam env)` again after this.

### Install from source

Download the source code (assuming you have git installed):

```sh
git clone https://github.com/mooreryan/computational_lab_notebooks.git
cd computational_lab_notebooks.git
dune build
```

Put the compiled binary somewhere on your path or set up a symbolic link to it.  For example:

```sh
ln -s $(pwd)/_build/default/bin/cln.exe ${HOME}/bin/cln.exe
```

That created a symbolic link in `${HOME}/bin`, which is on my path.

### Set up bash completion (optional)

If you want bash completions and are running Linux, copy the
`cln_bash_completions.sh` file to `/etc/bash_completion.d` (or
wherever you keep your bash completions):

```sh
sudo cp utils/cln_bash_completion.sh /etc/bash_completion.d/
```

To activate them for your current shell session, source the file:

```sh
. utils/cln_bash_completion.s
```

### Run the tests (optional)

#### Set up cram

If you want to run the tests, you need to [install cram](https://bitheap.org/cram/).

If you need to install python, you could do something like this:

```sh
sudo apt-get update && \
     sudo apt-get install -y wget \
                             python3 \
                             python3-distutils && \
     sudo ln -s $(which python3) /usr/bin/python
```

Then download and install cram:

```sh
cd ~/Downloads
wget https://bitheap.org/cram/cram-0.6.tar.gz
tar zxvf cram-0.6.tar.gz
cd cram-0.6
make install
```

Alternatively, you may already have python installed and want to install cram with pip: `pip install cram`.

#### Run tests

Now you can run the tests:

```sh
make test_all
```

Note that if you may still need to setup the opam environment if you haven't reopended a new shell:

```sh
eval $(opam env) && make test_all
```

## Usage

Check the help screen for usage info:

```
cln.exe help
```

## Examples

For some usage examples, see the cram tests in `<project root>/tests/cram`.  The `*.t` files are cram tests.  They look a bit weird at first but the walk through different scenarios of using the `cln.exe` CLI app.  Also, they are guaranteed to be up to date with whatever version of the code you're running since they are basically integration tests!

## License

Licensed under the Apache License, Version 2.0 or the MIT license, at your option. This program may not be copied, modified, or distributed except according to those terms.
