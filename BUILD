# Configuration setting for fastbuild mode.
config_setting(
    name = "fastbuild",
    values = {"compilation_mode": "fastbuild"},
)

# Configuration setting for debug mode.
config_setting(
    name = "debug",
    values = {"compilation_mode": "dbg"},
)

# Configuration setting for optimized mode.
config_setting(
    name = "optimized",
    values = {"compilation_mode": "opt"},
)

# Rust and C/C++ cross compilation settings

platform(
    name = "linux-x86_64",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
    ],
    visibility = ["//visibility:public"],
)

platform(
    name = "linux-x86_64-v2",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
        "//constraints/amd64:v2",
    ],
    visibility = ["//visibility:public"],
)

platform(
    name = "linux-x86_64-v3",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
        "//constraints/amd64:v3",
    ],
    visibility = ["//visibility:public"],
)

platform(
    name = "linux-x86_64-v4",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:x86_64",
        "//constraints/amd64:v4",
    ],
    visibility = ["//visibility:public"],
)

config_setting(
    name = "amd64_v2",
    constraint_values = ["//constraints/amd64:v2"],
)

config_setting(
    name = "amd64_v3",
    constraint_values = ["//constraints/amd64:v3"],
)

config_setting(
    name = "amd64_v4",
    constraint_values = ["//constraints/amd64:v4"],
)

platform(
    name = "linux-aarch64",
    constraint_values = [
        "@platforms//os:linux",
        "@platforms//cpu:aarch64",
    ],
    visibility = ["//visibility:public"],
)
