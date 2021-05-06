(lang dune 2.8)

(cram enable)

(generate_opam_files true)

(license "MIT or Apache-2.0")

(name computational_lab_notebooks)

(package
 (name computational_lab_notebooks)
 (version 0.2.0)
 (maintainers "Ryan Moore")
 (authors "Ryan Moore")
 (homepage "https://github.com/mooreryan/computational_lab_notebooks")
 (bug_reports "https://github.com/mooreryan/computational_lab_notebooks/issues")
 (synopsis "CLI program to help you manage your lab notebook with git and git annex")
 (depends core dune jingoo ppx_jane))
