load("@rules_rust//rust:defs.bzl", "rust_binary")
load("//:settings.bzl", "RUST_BUILD_FLAGS", "RUST_BUILD_FLAGS_PER_ARCH", "RUST_PLATFORMS_PER_ARCH")

version = "0.1.0"

ARCHS = [
    "arm64",
    # "arm64_v8_1a", # unstable
    # "arm64_v8_2a", # unstable
    # "arm64_v8_3a", # unstable
    # "arm64_v8_4a", # unstable
    # "arm64_v8_5a", # unstable
    # "arm64_v8_6a", # unstable
    # "arm64_v8_7a", # unstable
    # "arm64_v8_8a", # unstable
    # "arm64_v8_9a", # unstable
    # "arm64_v9a", # unstable
    # "arm64_v9_1a", # unstable
    # "arm64_v9_2a", # unstable
    # "arm64_v9_3a", # unstable
    # "arm64_v9_4a", # unstable
    # "arm64_v9_5a", # unstable
    # "arm64_v9_6a", # unstable
    "amd64",
    "amd64_v2",
    "amd64_v3",
    "amd64_v4",
]

rust_binary(
    name = "hello_world",
    srcs = [
        "src/main.rs",
    ],
    rustc_flags = RUST_BUILD_FLAGS,
    version = version,
    deps = [
        "@cargo//:mimalloc",
        "@cargo//:tokio",
    ],
)

[
    # Use gcr.io/distroless/cc-debian13
    # To run the binary in OCI container.
    rust_binary(
        name = "hello_world_%s" % arch,
        srcs = [
            "src/main.rs",
        ],
        platform = RUST_PLATFORMS_PER_ARCH[arch],
        rustc_flags = RUST_BUILD_FLAGS_PER_ARCH[arch],
        version = version,
        deps = [
            "@cargo//:mimalloc",
            "@cargo//:tokio",
        ],
    )
    for arch in ARCHS
]
