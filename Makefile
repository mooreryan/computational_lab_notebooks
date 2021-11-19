ARTIFACT_NAME = cln
BASH_COMPLETION_D = /etc/bash_completion.d
BROWSER = firefox
PACKAGE_NAME = computational_lab_notebooks
TEST_COV_D = /tmp/cln_coverage
TEST_D = tests
UTILS_D = utils


.PHONY: all
all: clean build_release install

.PHONY: build
build:
	dune build

.PHONY: build_mac
build_mac:
	dune build -j 1

.PHONY: build_release
build_release:
	dune build -p $(PACKAGE_NAME)

.PHONY: build_release_mac
build_release_mac:
	dune build -p $(PACKAGE_NAME) -j 1

.PHONY: check
check:
	dune build @check

.PHONY: clean
clean:
	dune clean

.PHONY: install
install:
	dune install -p $(PACKAGE_NAME)

.PHONY: install_mac
install_mac:
	dune install -p $(PACKAGE_NAME) -j 1

.PHONY: install_bash_completion
install_bash_completion:
	cp $(UTILS_D)/cln_bash_completion.sh $(BASH_COMPLETION_D)

.PHONY: send_coverage
send_coverage: test_coverage
	bisect-ppx-report send-to Coveralls --coverage-path $(TEST_COV_D)

.PHONY: test
test:
	dune test

.PHONY: test_mac
test_mac:
	dune test -j 1

.PHONY: test_coverage
test_coverage:
	if [ -d $(TEST_COV_D) ]; then rm -r $(TEST_COV_D); fi
	mkdir -p $(TEST_COV_D)
	BISECT_FILE=$(TEST_COV_D)/$(ARTIFACT_NAME) dune runtest --no-print-directory \
	  --instrument-with bisect_ppx --force
	bisect-ppx-report html --coverage-path $(TEST_COV_D)
	bisect-ppx-report summary --coverage-path $(TEST_COV_D)

.PHONY: test_coverage_open
test_coverage_open: test_coverage
	$(BROWSER) _coverage/index.html

.PHONY: uninstall
uninstall:
	dune uninstall


