open Memfd

let () =
  let opts =
    make_memfd_opts ~allow_sealing:true ~cloexec:true
      ~huge_tlb_flag:(Some Huge_TLB_2MB)
  in
  let fd_res = make_memfd ~name:"test_2mb" ~memfd_opts:opts in
  let fd = Result.get_ok fd_res in
  let _ = memfd_resize ~memfd:fd ~size:(2 * 1024 * 1024) in
  let _ =
    memfd_add_seals ~memfd:fd
      ~sl:[ Seal_seal; Seal_shrink; Seal_grow; Seal_write; Seal_future_write ]
  in
  ()
