external memfd_create_ : string -> bool -> bool -> bool -> int -> int
  = "caml_memfd_create"

external memfd_resize_ : int -> int -> int = "caml_memfd_resize"
external memfd_add_seal_ : int -> int -> int = "caml_memfd_add_seal"
external memfd_get_seal_ : int -> int = "caml_memfd_get_seal"

type huge_tlb_flag =
  | Huge_TLB_64KB
  | Huge_TLB_512KB
  | Huge_TLB_1MB
  | Huge_TLB_2MB
  | Huge_TLB_8MB
  | Huge_TLB_16MB
  | Huge_TLB_32MB
  | Huge_TLB_256MB
  | Huge_TLB_512MB
  | Huge_TLB_1GB
  | Huge_TLB_2GB
  | Huge_TLB_16GB

type seal_flag =
  | Seal_seal
  | Seal_shrink
  | Seal_grow
  | Seal_write
  | Seal_future_write
  | Invalid_seal

type memfd_err =
  | Create_fd
  | Create_fd_ver
  | Create_fd_sealing_hugetlb
  | Resize_fd
  | Add_seal
  | Get_seal

let int_of_huge_tlb_flag = function
  | Huge_TLB_64KB -> 1
  | Huge_TLB_512KB -> 2
  | Huge_TLB_1MB -> 3
  | Huge_TLB_2MB -> 4
  | Huge_TLB_8MB -> 5
  | Huge_TLB_16MB -> 6
  | Huge_TLB_32MB -> 7
  | Huge_TLB_256MB -> 8
  | Huge_TLB_512MB -> 9
  | Huge_TLB_1GB -> 10
  | Huge_TLB_2GB -> 11
  | Huge_TLB_16GB -> 12

let int_of_seal_flag = function
  | Seal_seal -> 1
  | Seal_shrink -> 2
  | Seal_grow -> 4
  | Seal_write -> 8
  | Seal_future_write -> 16
  | Invalid_seal -> 0

let seal_flag_of_string = function
  | 1 -> "Seal_seal"
  | 2 -> "Seal_shrink"
  | 4 -> "Seal_grow"
  | 8 -> "Seal_write"
  | 16 -> "Seal_future_write"
  | _ -> "Invalid_seal"

let memfd_err_to_string = function
  | Create_fd -> "Cannot create memfd"
  | Create_fd_ver -> "Linux kernel version must be >= 3.17"
  | Create_fd_sealing_hugetlb ->
      "Linux kernel version must be >= 4.16 to allow both sealing and huge page"
  | Resize_fd -> "Cannot resize memfd"
  | Add_seal -> "Cannot add seal to memfd"
  | Get_seal -> "Cannot get seal from memfd"

type memfd_opts = {
  allow_sealing : bool;
  cloexec : bool;
  huge_tlb_flag : huge_tlb_flag option;
}

let make_memfd_opts ~allow_sealing ~cloexec ~huge_tlb_flag =
  { allow_sealing; cloexec; huge_tlb_flag }

let make_default_memfd_opts () =
  { allow_sealing = false; cloexec = false; huge_tlb_flag = None }

let make_memfd_flag memfd_opts =
  let huge_tlb_flag = memfd_opts.huge_tlb_flag in
  let allow_flag = memfd_opts.allow_sealing in
  let cloexec_flag = memfd_opts.cloexec in
  if Option.is_some huge_tlb_flag then
    ( allow_flag,
      cloexec_flag,
      true,
      int_of_huge_tlb_flag (Option.get huge_tlb_flag) )
  else (allow_flag, cloexec_flag, false, 0)

let make_memfd ~name ~memfd_opts =
  let allow_flag, cloexec_flag, enable_huge_tlb, huge_tlb_flag =
    make_memfd_flag memfd_opts
  in
  let file_desc =
    memfd_create_ name allow_flag cloexec_flag enable_huge_tlb huge_tlb_flag
  in
  if file_desc = -1 then Error Create_fd
  else if file_desc = -2 then Error Create_fd_ver
  else if file_desc = -3 then Error Create_fd_sealing_hugetlb
  else Ok file_desc

let memfd_resize ~memfd ~size =
  let res = memfd_resize_ memfd size in
  if res = -1 then Error Resize_fd else Ok ()

let memfd_add_seals ~memfd ~sl =
  let flag = ref 0 in
  let _ = List.iter (fun v -> flag := !flag lor int_of_seal_flag v) sl in
  let res = memfd_add_seal_ memfd !flag in
  if res = -1 then Error Add_seal else Ok ()

let memfd_get_seals ~memfd =
  let seals = memfd_get_seal_ memfd in
  if seals = -1 then Error Get_seal
  else
    let all_flags =
      [ Seal_seal; Seal_shrink; Seal_grow; Seal_write; Seal_future_write ]
    in
    let res =
      List.fold_right
        (fun flag acc ->
          if seals land int_of_seal_flag flag = int_of_seal_flag flag then
            flag :: acc
          else acc)
        all_flags []
    in
    Ok res
