# Rust Bazel Cross-Compile Example (LLVM)

A minimal example of cross-compiling Rust to Linux (x86_64 and ARM64) using Bazel with the LLVM toolchain. Build on macOS and produce binaries for Linux targets.

## Features

- **Cross-compilation** from macOS (Apple Silicon) to Linux x86_64 and AArch64
- **LLVM toolchain** (v21.1.8) for linking with Debian Trixie sysroots
- **Microarchitecture variants** for optimized builds:
  - **x86-64**: baseline, v2, v3, v4 (AVX-512)
  - **AArch64**: baseline, v8.1a through v9.6a (SVE2, etc.)
- **Static linking** support with `crt-static`
- **Platform-specific output directories** to avoid cache invalidation when switching targets

## Prerequisites

- [Bazel](https://bazel.build/) (Bazelisk recommended)
- macOS (ARM64) host

## Quick Start

Build for the host platform (macOS):

```bash
bazel build //rust/hello_world:hello_world
```

Cross-compile for Linux x86_64:

```bash
bazel build //rust/hello_world:hello_world_amd64
```

Cross-compile for Linux ARM64:

```bash
bazel build //rust/hello_world:hello_world_arm64
```

## Architecture Variants

Build for specific microarchitecture levels:

```bash
# x86-64 with AVX2 (v3)
bazel build //rust/hello_world:hello_world_amd64_v3

# AArch64 v8.4a (e.g., Graviton 3, Neoverse V1)
bazel build //rust/hello_world:hello_world_arm64_v8_4a
```

## Build Modes

- **Debug** (default): `bazel build -c dbg //rust/hello_world:hello_world_amd64`
- **Release**: `bazel build -c opt //rust/hello_world:hello_world_amd64`

## Project Structure

```text
├── MODULE.bazel          # Bazel module deps (rules_rust, toolchains_llvm)
├── rust.MODULE.bazel     # Rust toolchain, LLVM, sysroots, crates
├── settings.bzl          # Build flags, platform mappings
├── BUILD                 # Platform definitions (linux-x86_64, linux-aarch64)
├── constraints/
│   ├── amd64/            # x86-64 microarchitecture constraints
│   └── arm64/            # AArch64 ISA version constraints
└── rust/
    └── hello_world/      # Example binary (Tokio + mimalloc)
```

## Dependencies

| Dependency      | Version               |
| --------------- | --------------------- |
| rules_rust      | 0.68.1                |
| toolchains_llvm | 1.6.0                 |
| platforms       | 1.0.0                 |
| Rust            | 1.93.1 (edition 2024) |
| LLVM            | 21.1.8                |

Sysroots are fetched from [cross-compilation-sysroots](https://github.com/amsokol/cross-compilation-sysroots) (Debian Trixie).

## License

MIT License — see [LICENSE](LICENSE).
