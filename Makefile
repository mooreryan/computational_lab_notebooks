TEST_D = $(PWD)/tests
CRAM_D = $(TEST_D)/cram
BUILD_D = $(PWD)/_build/default
CLN_EXE = $(BUILD_D)/bin/cln.exe
CRAM_EXE = cram

.PHONY: test_happy_path

test_happy_path:
	CLN_EXE=$(CLN_EXE) WORK_D=$(CRAM_D)/happy_path_d $(CRAM_EXE) $(CRAM_D)/happy_path.t
