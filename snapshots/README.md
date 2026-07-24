# Source snapshots

Each `*.cmake` file in this directory is a **snapshot**: it pins every source project of
the superbuild to an exact commit (and `origin` remote), so a full multi-repository state
can be committed here and reproduced later — for a demonstration, a paper, or a specific
piece of work.

A snapshot file is a list of, per project:

```cmake
set(MC_RTC_SUPERBUILD_SNAPSHOT_<NAME>_GIT_TAG <commit-sha>)
set(MC_RTC_SUPERBUILD_SNAPSHOT_<NAME>_REMOTE  <origin-url>)
```

## Usage

Generate one from the current on-disk state:

```shell
cmake -S <superbuild> -B <build> -DSNAPSHOT=<name>
cmake --build <build> --target save-snapshot   # writes snapshots/<name>.cmake
```

Reproduce a snapshot:

```shell
cmake -S <superbuild> -B <build> -DSNAPSHOT=<name>
cmake --build <build> --target clone
cmake --build <build> --target restore-snapshot
```

See the "Snapshots" section of the top-level `README.md` for the full workflow. These
files are meant to be committed; do not edit them by hand — regenerate with
`save-snapshot`.
