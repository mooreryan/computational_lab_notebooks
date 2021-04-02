TEST_D = $(PWD)/tests
CRAM_D = $(TEST_D)/cram
BUILD_D = $(PWD)/_build/default
CLN_EXE = $(BUILD_D)/bin/cln.exe
CRAM_EXE = cram

.PHONY: build
.PHONY: test_all
.PHONY: test_happy_path
.PHONY: test_remove

build:
	dune build

test_all: build test_happy_path test_remove

test_happy_path: build
	CLN_EXE=$(CLN_EXE) WORK_D=$(CRAM_D)/happy_path_d $(CRAM_EXE) $(CRAM_D)/happy_path.t

test_remove: build
	CLN_EXE=$(CLN_EXE) WORK_D=$(CRAM_D)/remove_d $(CRAM_EXE) $(CRAM_D)/remove.t
