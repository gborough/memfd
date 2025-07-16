# Memfd
Create and manage Linux Memory Mapped Files

## What is memfd

As per Linux manual, "memfd_create() creates an anonymous file and returns a file descriptor that refers to it. The file behaves like a regular file, and so can be modified, truncated, memory-mapped, and so on. However, unlike a regular file, it lives in RAM and has a volatile backing storage. Once all references to the file are dropped, it is automatically released. Anonymous memory is used for all backing pages of the file.  Therefore, files created by memfd_create() have the same semantics as other anonymous memory allocations such as those allocated using mmap(2) with the MAP_ANONYMOUS flag."

This library manages the call to Linux memfd_create(), including kernel version guard and other conveniences.

## Unix.file_descr and memfd

This library is unopinionated about the conversion between Unix.file_descr and memfd, therefore no such function is exposed. You can check out this line in the test for reference: