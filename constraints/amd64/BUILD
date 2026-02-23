package(default_visibility = ["//visibility:public"])

# x86-64 microarchitecture level for the target platform.
# Maps to rustc's -Ctarget-cpu=x86-64-v{1,2,3,4}.
# See https://en.wikipedia.org/wiki/X86-64#Microarchitecture_levels
constraint_setting(
    name = "amd64",
)

constraint_value(
    name = "v2",
    constraint_setting = ":amd64",
)

constraint_value(
    name = "v3",
    constraint_setting = ":amd64",
)

constraint_value(
    name = "v4",
    constraint_setting = ":amd64",
)
