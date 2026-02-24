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

## Static Linking and the lld IRELATIVE Bug

Static binaries built with LLVM/lld >= 20 and glibc segfault immediately at startup.
This section explains the root cause and the workaround used in this project.

### Symptoms

A statically linked binary (`-Ctarget-feature=+crt-static`) crashes on launch:

```sh
zsh: segmentation fault  ./hello_world_static_amd64
```

The crash happens before `main()` is reached — inside glibc's startup code (`ARCH_APPLY_IREL`).

### Root Cause

The bug is in lld's handling of relocations for static glibc binaries. Three things combine to produce the crash:

1. **glibc uses IFUNC** (indirect functions) for optimized implementations of `memcpy`, `memset`, `strlen`, etc. These generate `R_X86_64_IRELATIVE` (or `R_AARCH64_IRELATIVE`) relocations in the binary.

2. **lld puts all relocations into `.rela.dyn`** — both `IRELATIVE` entries (for IFUNCs) and `GLOB_DAT` entries (for weak undefined symbols like `__gmon_start__`, `__cxa_finalize`, `statx`, etc.). It then defines `__rela_iplt_start` / `__rela_iplt_end` to span the **entire** `.rela.dyn` section. The relevant code is in [`lld/ELF/Relocations.cpp`](https://github.com/llvm/llvm-project/blob/main/lld/ELF/Relocations.cpp):

   ```cpp
   RelocationBaseSection &elf::getIRelativeSection(Ctx &ctx) {
     return ctx.arg.androidPackDynRelocs ? *ctx.in.relaPlt
                                         : *ctx.mainPart->relaDyn;
   }
   ```

   GNU ld, by contrast, puts `IRELATIVE` into a separate `.rela.iplt` section.

3. **glibc's `ARCH_APPLY_IREL`** iterates from `__rela_iplt_start` to `__rela_iplt_end` and calls every entry's `r_addend` as a function pointer — **without checking the relocation type**. When it hits a `GLOB_DAT` entry (addend = 0), it calls address `0x0` and segfaults.

You can confirm the issue by inspecting the binary:

```bash
llvm-readelf -r ./hello_world_static_amd64 | grep GLOB_DAT
```

If any `GLOB_DAT` entries appear, the binary will segfault.

### Workaround

The fix is to eliminate `GLOB_DAT` entries from `.rela.dyn` by providing explicit definitions for the weak undefined symbols via `--defsym`:

```starlark
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
        "ADDRESS", "COLLATE", "IDENTIFICATION", "MEASUREMENT",
        "MESSAGES", "MONETARY", "NAME", "PAPER", "TELEPHONE", "TIME",
    ]
]

_BUILD_FLAGS_STATIC = [
    "-Ctarget-feature=+crt-static",
    "-Crelocation-model=static",
] + ["-Clink-arg=-Wl,--defsym=%s=0" % s for s in _STATIC_WEAK_SYMS]
```

Defining these symbols as `0` is safe because they are all `WEAK` — glibc checks whether they are non-null before calling them and falls back to alternatives when they are `0`.

### Diagnosing New Symbols

The set of weak symbols depends on the glibc version in the sysroot and the host platform. Different host/target combinations may produce different `GLOB_DAT` entries. If a static binary segfaults after updating the sysroot or building on a new host:

1. Build the binary.
2. Check for remaining `GLOB_DAT` entries:

   ```bash
   llvm-readelf -r ./my_binary | grep GLOB_DAT
   ```

3. Add any new symbol names to the `_STATIC_WEAK_SYMS` list in `settings.bzl`.
4. Rebuild and verify:

   ```bash
   llvm-readelf -r ./my_binary | grep GLOB_DAT
   # (should produce no output)
   ```

### Status

This is an unfixed bug in lld as of LLVM 22 (February 2026). No GitHub issue has been filed yet. The proper fix should come from lld — either by placing `IRELATIVE` into a separate `.rela.iplt` section, or by defining `__rela_iplt_start` / `__rela_iplt_end` to span only the `IRELATIVE` entries within `.rela.dyn`.

## License

MIT License — see [LICENSE](LICENSE).
