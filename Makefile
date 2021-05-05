TEST_D = tests
UTILS_D = utils
BASH_COMPLETION_D = /etc/bash_completion.d

.PHONY: build
.PHONY: check
.PHONY: clean
.PHONY: test

build:
	dune build

check:
	dune build @check

clean:
	dune clean

install: build
	dune install

install_bash_completion:
	cp $(UTILS_D)/cln_bash_completion.sh $(BASH_COMPLETION_D)

uninstall:
	dune uninstall

test:
	dune runtest
