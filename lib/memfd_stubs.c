#define _GNU_SOURCE
#include <unistd.h>
#include <fcntl.h>
#include <stdbool.h>
#include <linux/memfd.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/utsname.h>
#include <caml/alloc.h>
#include <caml/mlvalues.h>
#include <caml/memory.h>

CAMLprim value caml_memfd_create(value v_name, value v_allow_sealing, value v_cloexec, value v_enable_huge_tlb, value v_huge_tlb_flag)
{
    struct utsname buffer;
    int major = 0, minor = 0;

    if (uname(&buffer) != 0)
    {
        return Val_int(-1);
    }

    sscanf(buffer.release, "%d.%d", &major, &minor);

    if (major <= 3 && minor < 17)
    {
        return Val_int(-2);
    }

    unsigned int flags = 0;

    CAMLparam5(v_name, v_allow_sealing, v_cloexec, v_enable_huge_tlb, v_huge_tlb_flag);
    const char *name = String_val(v_name);
    bool allow_sealing = Bool_val(v_allow_sealing);
    bool cloexec = Bool_val(v_cloexec);
    bool enable_huge_tlb = Bool_val(v_enable_huge_tlb);
    unsigned int huge_tlb_flag = Int_val(v_huge_tlb_flag);

    if (enable_huge_tlb && major <= 4 && minor < 14)
    {
        return Val_int(-2);
    }

    if (allow_sealing && enable_huge_tlb && major <= 4 && minor < 16)
    {
        return Val_int(-3);
    }

    if (allow_sealing)
        flags |= MFD_ALLOW_SEALING;
    if (cloexec)
        flags |= MFD_CLOEXEC;
    if (enable_huge_tlb)
    {
        flags |= MFD_HUGETLB;
        switch (huge_tlb_flag)
        {
        case 1:
            flags |= MFD_HUGE_64KB;
            break;
        case 2:
            flags |= MFD_HUGE_512KB;
            break;
        case 3:
            flags |= MFD_HUGE_1MB;
            break;
        case 4:
            flags |= MFD_HUGE_2MB;
            break;
        case 5:
            flags |= MFD_HUGE_8MB;
            break;
        case 6:
            flags |= MFD_HUGE_16MB;
            break;
        case 7:
            flags |= MFD_HUGE_32MB;
            break;
        case 8:
            flags |= MFD_HUGE_256MB;
            break;
        case 9:
            flags |= MFD_HUGE_512MB;
            break;
        case 10:
            flags |= MFD_HUGE_1GB;
            break;
        case 11:
            flags |= MFD_HUGE_2GB;
            break;
        case 12:
            flags |= MFD_HUGE_16GB;
            break;
        default:
            break;
        }
    }

    int fd = memfd_create(name, flags);

    CAMLreturn(Val_int(fd));
}

CAMLprim value caml_memfd_resize(value v_fd, value v_size)
{
    CAMLparam2(v_fd, v_size);
    int fd = Int_val(v_fd);
    ssize_t size = Int_val(v_size);

    int res = ftruncate(fd, size);

    CAMLreturn(Val_int(res));
}

CAMLprim value caml_memfd_add_seal(value v_fd, value v_seals)
{
    CAMLparam2(v_fd, v_seals);
    int fd = Int_val(v_fd);
    unsigned int seal = Unsigned_int_val(v_seals);

    int res = fcntl(fd, F_ADD_SEALS, seal);

    CAMLreturn(Val_int(res));
}

CAMLprim value caml_memfd_get_seal(value v_fd)
{
    CAMLparam1(v_fd);
    int fd = Int_val(v_fd);

    unsigned int seals = fcntl(fd, F_GET_SEALS);

    CAMLreturn(Val_int(seals));
}