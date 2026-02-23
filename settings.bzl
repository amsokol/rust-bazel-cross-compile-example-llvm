"""
Module of global project settings.
"""

# Rust toolchains for different architectures.
RUST_PLATFORMS_PER_ARCH = {
    "arm64": "//:linux-aarch64",
    "amd64": "//:linux-x86_64",
    "amd64_v2": "//:linux-x86_64-v2",
    "amd64_v3": "//:linux-x86_64-v3",
    "amd64_v4": "//:linux-x86_64-v4",
}

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
RUST_AMD64_MICROARCH_FLAGS = select({
    "//:amd64_v4": ["-Ctarget-cpu=x86-64-v4"],
    "//:amd64_v3": ["-Ctarget-cpu=x86-64-v3"],
    "//:amd64_v2": ["-Ctarget-cpu=x86-64-v2"],
    "//conditions:default": [],
})

RUST_BUILD_FLAGS = select({
    "//:optimized": RUST_BUILD_FLAGS_RELEASE,
    "//conditions:default": RUST_BUILD_FLAGS_DEBUG,
})

RUST_BUILD_FLAGS_PER_ARCH = {
    "arm64": select({
        "//:optimized": RUST_BUILD_FLAGS_RELEASE,
        "//conditions:default": RUST_BUILD_FLAGS_DEBUG,
    }),
    "amd64": select({
        "//:optimized": RUST_BUILD_FLAGS_RELEASE,
        "//conditions:default": RUST_BUILD_FLAGS_DEBUG,
    }),
    "amd64_v2": select({
        "//:optimized": RUST_BUILD_FLAGS_RELEASE,
        "//conditions:default": RUST_BUILD_FLAGS_DEBUG,
    }) + RUST_AMD64_MICROARCH_FLAGS,
    "amd64_v3": select({
        "//:optimized": RUST_BUILD_FLAGS_RELEASE,
        "//conditions:default": RUST_BUILD_FLAGS_DEBUG,
    }) + RUST_AMD64_MICROARCH_FLAGS,
    "amd64_v4": select({
        "//:optimized": RUST_BUILD_FLAGS_RELEASE,
        "//conditions:default": RUST_BUILD_FLAGS_DEBUG,
    }) + RUST_AMD64_MICROARCH_FLAGS,
}

RUST_BUILD_FLAGS_STATIC_PER_ARCH = {
    "arm64": select({
        "//:optimized": RUST_BUILD_FLAGS_RELEASE + RUST_BUILD_FLAGS_STATIC,
        "//conditions:default": RUST_BUILD_FLAGS_DEBUG + RUST_BUILD_FLAGS_STATIC,
    }),
    "amd64": select({
        "//:optimized": RUST_BUILD_FLAGS_RELEASE + RUST_BUILD_FLAGS_STATIC,
        "//conditions:default": RUST_BUILD_FLAGS_DEBUG + RUST_BUILD_FLAGS_STATIC,
    }),
    "amd64_v2": select({
        "//:optimized": RUST_BUILD_FLAGS_RELEASE + RUST_BUILD_FLAGS_STATIC,
        "//conditions:default": RUST_BUILD_FLAGS_DEBUG + RUST_BUILD_FLAGS_STATIC,
    }) + RUST_AMD64_MICROARCH_FLAGS,
    "amd64_v3": select({
        "//:optimized": RUST_BUILD_FLAGS_RELEASE + RUST_BUILD_FLAGS_STATIC,
        "//conditions:default": RUST_BUILD_FLAGS_DEBUG + RUST_BUILD_FLAGS_STATIC,
    }) + RUST_AMD64_MICROARCH_FLAGS,
    "amd64_v4": select({
        "//:optimized": RUST_BUILD_FLAGS_RELEASE + RUST_BUILD_FLAGS_STATIC,
        "//conditions:default": RUST_BUILD_FLAGS_DEBUG + RUST_BUILD_FLAGS_STATIC,
    }) + RUST_AMD64_MICROARCH_FLAGS,
}
