(** Type of huge page sizes. The most common sizes are 2MB and 1GB. Check
    /proc/meminfo for the size your system currently uses. *)
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

(** Type of file sealing flags. *)
type seal_flag =
  | Seal_seal  (** F_SEAL_SEAL *)
  | Seal_shrink  (** F_SEAL_SHRINK *)
  | Seal_grow  (** F_SEAL_GROW *)
  | Seal_write  (** F_SEAL_WRITE *)
  | Seal_future_write  (** F_SEAL_FUTURE_WRITE *)
  | Invalid_seal

(** Type of memfd ops errors. *)
type memfd_err =
  | Create_fd  (** Generic memfd_create failure *)
  | Create_fd_ver  (** Linux kernel version is less than 3.17 *)
  | Create_fd_sealing_hugetlb
      (** Linux kernel version must be over 4.16 to enable both sealing and huge
          page *)
  | Resize_fd  (** Resize failure *)
  | Add_seal  (** Add seal failure *)
  | Get_seal  (** Get seal failure *)

type memfd_opts = {
  allow_sealing : bool;
  cloexec : bool;
  huge_tlb_flag : huge_tlb_flag option;
}
(** Type of memfd creation options. *)

val make_memfd_opts :
  allow_sealing:bool ->
  cloexec:bool ->
  huge_tlb_flag:huge_tlb_flag option ->
  memfd_opts
(**[make_memfd_opts] [allow_sealing] [cloexec] [huge_tlb_flag] makes the memfd
   options. *)

val make_default_memfd_opts : unit -> memfd_opts
(**[make_default_memfd_opts] makes the memfd options with default options *)

val make_memfd : name:string -> memfd_opts:memfd_opts -> (int, memfd_err) result
(**[make_memfd] [name] [opts] makes the memfd using [name] and [memfd_opts] as
   options. *)

val memfd_resize : memfd:int -> size:int -> (unit, memfd_err) result
(** [memfd_resize] sets a [memfd] to [size]. If huge page is enabled, you must
    set the size to the align with your page size, e.g. if page size is 2MB, you
    can set 2 * 1024 * 1024. Enough huge pages must also be free. *)

val memfd_add_seals : memfd:int -> sl:seal_flag list -> (unit, memfd_err) result
(** [memfd_add_seals] adds a list of seals [sl] to a [memfd]. *)

val memfd_get_seals : memfd:int -> (seal_flag list, memfd_err) result
(** [memfd_get_seals] gets a list of seals from a [memfd]. Also doubles as a
    validator for whether a file descriptor is a memfd. *)

val int_of_seal_flag : seal_flag -> int
(** [int_of_seal_flag] is a helper that converts a seal_flag to integer. *)

val seal_flag_of_string : int -> string
(** [seal_flag_of_string] is a helper that converts a seal_flag in integer
    representation to string. *)

val memfd_err_to_string : memfd_err -> string
