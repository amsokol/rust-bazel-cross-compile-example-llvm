load("@rules_rust//rust:defs.bzl", "rust_binary")
load("//:settings.bzl", "RUST_BUILD_FLAGS", "RUST_BUILD_FLAGS_PER_ARCH", "RUST_PLATFORMS_PER_ARCH")

version = "0.1.0"

ARCHS = [
    "arm64",
    "amd64",
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
