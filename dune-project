(lang dune 2.7)

(name memfd)

(generate_opam_files true)

(source
 (github gborough/memfd))

(authors "Geoffrey Borough <geoffrey.borough@outlook.com>")

(maintainers "Geoffrey Borough <geoffrey.borough@outlook.com>")

(license MIT)

(documentation https://gborough.github.io/memfd/memfd)

(package
 (name memfd)
 (synopsis "Create and manage Linux Memory Mapped Files")
 (description
  "A library to create and manage the Linux Memory Mapped Files(memfd). Supports Linux kernel version >= 3.17")
 (depends
  (ocaml
   (>= 4.08.0)))
 (tags
  (linux memfd)))

; See the complete stanza docs at https://dune.readthedocs.io/en/stable/reference/dune-project/index.html
