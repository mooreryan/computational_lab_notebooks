TEST_D = tests
UTILS_D = utils
BASH_COMPLETION_D = /etc/bash_completion.d
TEST_COV_D = /tmp/cln_coverage

.PHONY: build
.PHONY: check
.PHONY: clean
.PHONY: test
.PHONY: test_coverage
.PHONY: send_coverage

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

test_coverage:
	if [ -d $(TEST_COV_D) ]; then rm -r $(TEST_COV_D); fi
	mkdir -p $(TEST_COV_D)
	dune runtest --no-print-directory \
	  --instrument-with bisect_ppx --force
	bisect-ppx-report html --coverage-path $(TEST_COV_D)
	bisect-ppx-report summary --coverage-path $(TEST_COV_D)

send_coverage: test_coverage
	bisect-ppx-report send-to Coveralls --coverage-path $(TEST_COV_D)
