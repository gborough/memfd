open Memfd

let%expect_test "memfd_create" =
  let opts =
    make_memfd_opts ~allow_sealing:true ~cloexec:true
      ~huge_tlb_flag:(Some Huge_TLB_2MB)
  in
  let fd_res = make_memfd ~name:"test_2mb" ~memfd_opts:opts in
  let fd = Result.get_ok fd_res in
  let resize = memfd_resize ~memfd:fd ~size:(2 * 1024 * 1024) in
  let int_to_fd (fd : int) : Unix.file_descr = Obj.magic fd in
  let stats = Unix.fstat @@ int_to_fd fd in
  let add_seals =
    memfd_add_seals ~memfd:fd
      ~sl:[ Seal_seal; Seal_shrink; Seal_grow; Seal_write; Seal_future_write ]
  in
  let get_seals = memfd_get_seals ~memfd:fd in
  Printf.printf "Create fd ok: %b\n" (Result.is_ok @@ fd_res);
  Printf.printf "Resize fd ok: %b\n" (Result.is_ok @@ resize);
  Printf.printf "Add seal ok: %b\n" (Result.is_ok @@ add_seals);
  Printf.printf "Get seal ok: %b\n" (Result.is_ok @@ get_seals);
  List.iteri
    (fun i v ->
      Printf.printf "Got flag %d: %s\n" (i + 1)
        (seal_flag_of_string @@ int_of_seal_flag v))
    (Result.get_ok @@ get_seals);
  Printf.printf "File size: %d\n" stats.st_size;
  [%expect
    {|
    Create fd ok: true
    Resize fd ok: true
    Add seal ok: true
    Get seal ok: true
    Got flag 1: Seal_seal
    Got flag 2: Seal_shrink
    Got flag 3: Seal_grow
    Got flag 4: Seal_write
    Got flag 5: Seal_future_write
    File size: 2097152|}]
