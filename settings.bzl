"""
Module of global project settings.
"""

load("//constraints/amd64:defs.bzl", "AMD64_VARIANTS")
load("//constraints/arm64:defs.bzl", "ARM64_VARIANTS")

# Rust toolchains for different architectures.
RUST_PLATFORMS_PER_ARCH = dict(
    [
        ("arm64", "//:linux-aarch64"),
        ("amd64", "//:linux-x86_64"),
    ] +
    [("arm64_%s" % v, "//:linux-aarch64-%s" % v) for v in ARM64_VARIANTS] +
    [("amd64_%s" % v, "//:linux-x86_64-%s" % v) for v in AMD64_VARIANTS],
)

_BUILD_FLAGS_DEBUG = [
    "-Copt-level=0",
]

_BUILD_FLAGS_RELEASE = [
    "-Clink-arg=-flto",
    "-Clink-arg=-s",
    "-Ccodegen-units=1",
    "-Cpanic=abort",
    "-Copt-level=3",
    "-Cstrip=symbols",
]

# lld bug workaround: lld puts IRELATIVE and GLOB_DAT into the same .rela.dyn
# section, and __rela_iplt_start/__rela_iplt_end span both. glibc's
# ARCH_APPLY_IREL blindly calls every entry's addend as a function pointer,
# segfaulting on GLOB_DAT entries (addend=0). Defining the weak undefined
# symbols eliminates GLOB_DAT entries, leaving only IRELATIVE in .rela.dyn.
_STATIC_WEAK_SYMS = [
    "__gmon_start__",
    "__cxa_finalize",
    "__cxa_thread_atexit_impl",
    "_ITM_deregisterTMCloneTable",
    "_ITM_registerTMCloneTable",
    "statx",
] + [
    "_nl_current_LC_%s_used" % loc
    for loc in [
        "ADDRESS",
        "COLLATE",
        "IDENTIFICATION",
        "MEASUREMENT",
        "MESSAGES",
        "MONETARY",
        "NAME",
        "PAPER",
        "TELEPHONE",
        "TIME",
    ]
]

_BUILD_FLAGS_STATIC = [
    "-Ctarget-feature=+crt-static",
    "-Crelocation-model=static",
] + ["-Clink-arg=-Wl,--defsym=%s=0" % s for s in _STATIC_WEAK_SYMS]

# Selects the right -Ctarget-cpu for x86-64 microarchitecture levels.
# Falls back to no flag (baseline x86-64) when no constraint is set.
_AMD64_MICROARCH_FLAGS = select(dict(
    [("//:amd64_%s" % v, ["-Ctarget-cpu=x86-64-%s" % v]) for v in AMD64_VARIANTS] +
    [("//conditions:default", [])],
))

# Selects the right -Ctarget-feature for AArch64 ISA versions.
# Falls back to no flag (baseline ARMv8.0-A) when no constraint is set.
_ARM64_MICROARCH_FLAGS = select(dict(
    [("//:arm64_%s" % v, ["-Ctarget-feature=+%s" % v.replace("_", ".")]) for v in ARM64_VARIANTS] +
    [("//conditions:default", [])],
))

RUST_BUILD_FLAGS = select({
    "//:optimized": _BUILD_FLAGS_RELEASE,
    "//conditions:default": _BUILD_FLAGS_DEBUG,
})

RUST_BUILD_FLAGS_STATIC = select({
    "//:optimized": _BUILD_FLAGS_RELEASE + _BUILD_FLAGS_STATIC,
    "//conditions:default": _BUILD_FLAGS_DEBUG + _BUILD_FLAGS_STATIC,
})

RUST_BUILD_FLAGS_PER_ARCH = dict(
    [
        ("arm64", RUST_BUILD_FLAGS),
        ("amd64", RUST_BUILD_FLAGS),
    ] +
    [("arm64_%s" % v, RUST_BUILD_FLAGS + _ARM64_MICROARCH_FLAGS) for v in ARM64_VARIANTS] +
    [("amd64_%s" % v, RUST_BUILD_FLAGS + _AMD64_MICROARCH_FLAGS) for v in AMD64_VARIANTS],
)

RUST_BUILD_FLAGS_STATIC_PER_ARCH = dict(
    [
        ("arm64", RUST_BUILD_FLAGS_STATIC),
        ("amd64", RUST_BUILD_FLAGS_STATIC),
    ] +
    [("arm64_%s" % v, RUST_BUILD_FLAGS_STATIC + _ARM64_MICROARCH_FLAGS) for v in ARM64_VARIANTS] +
    [("amd64_%s" % v, RUST_BUILD_FLAGS_STATIC + _AMD64_MICROARCH_FLAGS) for v in AMD64_VARIANTS],
)
