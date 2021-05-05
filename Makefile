TEST_D = tests
UTILS_D = utils
CRAM_D = $(TEST_D)/cram
BUILD_D = _build
CLN_EXE = $(BUILD_D)/install/default/bin/cln
CRAM_EXE = cram
BASH_COMPLETION_D = /etc/bash_completion.d

.PHONY: build
.PHONY: check
.PHONY: clean
.PHONY: test
.PHONY: test_happy_path
.PHONY: test_remove

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
