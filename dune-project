(lang dune 2.8)

(generate_opam_files true)

(license "MIT or Apache-2.0")

(package
 (name computational_lab_notebooks)
 (synopsis "CLI program to help you manage your lab notebook with git and git annex.")
 (depends core dune jingoo ppx_jane))
