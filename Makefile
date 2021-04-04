TEST_D = tests
UTILS_D = utils
CRAM_D = $(TEST_D)/cram
BUILD_D = _build
CLN_EXE = $(BUILD_D)/install/default/bin/cln
CRAM_EXE = cram
BASH_COMPLETION_D = /etc/bash_completion.d

.PHONY: build
.PHONY: check
.PHONY: test
.PHONY: test_happy_path
.PHONY: test_remove

build:
	dune build

check:
	dune build @check

install:
	dune install

install_bash_completion:
	cp $(UTILS_D)/cln_bash_completion.sh $(BASH_COMPLETION_D)

uninstall:
	dune uninstall

test: build test_happy_path test_remove

# Cramtests currently need the env vars prefixed with $(PWD).
test_happy_path: build
	CLN_EXE=$(PWD)/$(CLN_EXE) \
	  WORK_D=$(PWD)/$(CRAM_D)/happy_path_d \
	  $(CRAM_EXE) $(CRAM_D)/happy_path.t

test_remove: build
	CLN_EXE=$(PWD)/$(CLN_EXE) \
	  WORK_D=$(PWD)/$(CRAM_D)/remove_d \
	  $(CRAM_EXE) $(CRAM_D)/remove.t
