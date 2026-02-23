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

RUST_BUILD_FLAGS_DEBUG = [
    "-Copt-level=0",
]

RUST_BUILD_FLAGS_RELEASE = [
    "-Clink-arg=-flto",
    "-Clink-arg=-s",
    "-Ccodegen-units=1",
    "-Cpanic=abort",
    "-Copt-level=3",
    "-Cstrip=symbols",
]

# IMPORTANT: Does not work with LLVM >= v20 because of "segmentation fault" error
# of the result "static-pie" linked binary.
# Flags to turn off PIE do not work:
# "-Crelocation-model=static",
# "-Clink-arg=-no-pie",
RUST_BUILD_FLAGS_STATIC = [
    "-Ctarget-feature=+crt-static",
    "-Clink-arg=-Wl,--no-dynamic-linker",
]

# Selects the right -Ctarget-cpu for x86-64 microarchitecture levels.
# Falls back to no flag (baseline x86-64) when no constraint is set.
RUST_AMD64_MICROARCH_FLAGS = select(dict(
    [("//:amd64_%s" % v, ["-Ctarget-cpu=x86-64-%s" % v]) for v in AMD64_VARIANTS] +
    [("//conditions:default", [])],
))

# Selects the right -Ctarget-feature for AArch64 ISA versions.
# Falls back to no flag (baseline ARMv8.0-A) when no constraint is set.
RUST_ARM64_MICROARCH_FLAGS = select(dict(
    [("//:arm64_%s" % v, ["-Ctarget-feature=+%s" % v.replace("_", ".")]) for v in ARM64_VARIANTS] +
    [("//conditions:default", [])],
))

RUST_BUILD_FLAGS = select({
    "//:optimized": RUST_BUILD_FLAGS_RELEASE,
    "//conditions:default": RUST_BUILD_FLAGS_DEBUG,
})

_OPT_FLAGS = select({
    "//:optimized": RUST_BUILD_FLAGS_RELEASE,
    "//conditions:default": RUST_BUILD_FLAGS_DEBUG,
})

_OPT_STATIC_FLAGS = select({
    "//:optimized": RUST_BUILD_FLAGS_RELEASE + RUST_BUILD_FLAGS_STATIC,
    "//conditions:default": RUST_BUILD_FLAGS_DEBUG + RUST_BUILD_FLAGS_STATIC,
})

RUST_BUILD_FLAGS_PER_ARCH = dict(
    [
        ("arm64", _OPT_FLAGS),
        ("amd64", _OPT_FLAGS),
    ] +
    [("arm64_%s" % v, _OPT_FLAGS + RUST_ARM64_MICROARCH_FLAGS) for v in ARM64_VARIANTS] +
    [("amd64_%s" % v, _OPT_FLAGS + RUST_AMD64_MICROARCH_FLAGS) for v in AMD64_VARIANTS],
)

RUST_BUILD_FLAGS_STATIC_PER_ARCH = dict(
    [
        ("arm64", _OPT_STATIC_FLAGS),
        ("amd64", _OPT_STATIC_FLAGS),
    ] +
    [("arm64_%s" % v, _OPT_STATIC_FLAGS + RUST_ARM64_MICROARCH_FLAGS) for v in ARM64_VARIANTS] +
    [("amd64_%s" % v, _OPT_STATIC_FLAGS + RUST_AMD64_MICROARCH_FLAGS) for v in AMD64_VARIANTS],
)
