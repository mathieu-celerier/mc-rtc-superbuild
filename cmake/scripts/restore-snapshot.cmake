cmake_minimum_required(VERSION 3.20)

# Check out, for every project, the commit (and origin remote) recorded in a snapshot.
#
# Expected variables (passed with -D):
#   SNAPSHOT       name of the snapshot (used for messages)
#   MANIFEST       path to the project manifest (one "NAME|SOURCE_DIR" per line)
#   SNAPSHOT_FILE  path to snapshots/<name>.cmake defining the pinned values
#
# Safety: a project is left untouched (with an error) when its working tree has
# uncommitted changes or unpushed local commits, so that no local work is ever lost.

if("${SNAPSHOT}" STREQUAL "")
  message(
    FATAL_ERROR
      "No snapshot name provided. Configure with -DSNAPSHOT=<name> before running restore-snapshot."
  )
endif()
if(NOT EXISTS "${SNAPSHOT_FILE}")
  message(FATAL_ERROR "Snapshot file not found: ${SNAPSHOT_FILE}")
endif()
if(NOT EXISTS "${MANIFEST}")
  message(FATAL_ERROR "Manifest not found: ${MANIFEST}")
endif()

# Load the pinned values (defines MC_RTC_SUPERBUILD_SNAPSHOT_<NAME>_GIT_TAG / _REMOTE)
include("${SNAPSHOT_FILE}")

file(STRINGS "${MANIFEST}" _entries)

set(_restored 0)
set(_skipped 0)
set(_failed 0)

foreach(_entry ${_entries})
  if("${_entry}" STREQUAL "")
    continue()
  endif()
  string(REPLACE "|" ";" _parts "${_entry}")
  list(GET _parts 0 _name)
  list(GET _parts 1 _src)

  set(_sha "${MC_RTC_SUPERBUILD_SNAPSHOT_${_name}_GIT_TAG}")
  set(_remote "${MC_RTC_SUPERBUILD_SNAPSHOT_${_name}_REMOTE}")

  if("${_sha}" STREQUAL "")
    # Not part of this snapshot
    continue()
  endif()

  if(NOT EXISTS "${_src}/.git")
    message(
      STATUS "[SKIP] ${_name}: ${_src} is not cloned yet (run the 'clone' target first)"
    )
    math(EXPR _skipped "${_skipped} + 1")
    continue()
  endif()

  # -- Safety: refuse to touch a dirty working tree
  execute_process(
    COMMAND git status --porcelain --untracked-files=no
    WORKING_DIRECTORY "${_src}"
    OUTPUT_VARIABLE _dirty
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  if(NOT "${_dirty}" STREQUAL "")
    message(
      "[SKIP] ${_name}: uncommitted changes, please commit or stash before restoring"
    )
    math(EXPR _skipped "${_skipped} + 1")
    continue()
  endif()

  # -- Safety: refuse when the current branch has commits not pushed upstream
  execute_process(
    COMMAND git symbolic-ref --short -q HEAD
    WORKING_DIRECTORY "${_src}"
    OUTPUT_VARIABLE _branch
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  if(NOT "${_branch}" STREQUAL "")
    execute_process(
      COMMAND git rev-list --count "@{u}.."
      WORKING_DIRECTORY "${_src}"
      OUTPUT_VARIABLE _ahead
      OUTPUT_STRIP_TRAILING_WHITESPACE
      RESULT_VARIABLE _ahead_err
    )
    if(NOT _ahead_err AND NOT "${_ahead}" STREQUAL "0")
      message(
        "[SKIP] ${_name}: branch '${_branch}' has ${_ahead} unpushed commit(s), push or back them up before restoring"
      )
      math(EXPR _skipped "${_skipped} + 1")
      continue()
    endif()
  endif()

  # -- Make sure origin points at the recorded remote
  if(NOT "${_remote}" STREQUAL "")
    execute_process(
      COMMAND git remote get-url origin
      WORKING_DIRECTORY "${_src}"
      OUTPUT_VARIABLE _current_remote
      OUTPUT_STRIP_TRAILING_WHITESPACE
    )
    if(NOT "${_current_remote}" STREQUAL "${_remote}")
      message(STATUS "${_name}: setting origin to ${_remote}")
      execute_process(
        COMMAND git remote set-url origin "${_remote}" WORKING_DIRECTORY "${_src}"
      )
    endif()
  endif()

  # -- Fetch and check out the recorded commit (detached HEAD)
  execute_process(COMMAND git fetch --quiet origin WORKING_DIRECTORY "${_src}")
  # Try a targeted fetch too in case the commit is not reachable from a branch tip
  execute_process(
    COMMAND git fetch --quiet origin "${_sha}"
    WORKING_DIRECTORY "${_src}"
    ERROR_QUIET
  )

  execute_process(
    COMMAND git checkout --quiet --detach "${_sha}"
    WORKING_DIRECTORY "${_src}"
    RESULT_VARIABLE _checkout_err
  )
  if(_checkout_err)
    message("[FAIL] ${_name}: cannot check out ${_sha} (unreachable commit?)")
    math(EXPR _failed "${_failed} + 1")
    continue()
  endif()

  # Restore nested submodules to the recorded state
  execute_process(
    COMMAND git submodule update --init --recursive
    WORKING_DIRECTORY "${_src}"
    OUTPUT_QUIET
  )

  message(STATUS "Restored ${_name} to ${_sha}")
  math(EXPR _restored "${_restored} + 1")
endforeach()

message(
  STATUS
    "Snapshot '${SNAPSHOT}': ${_restored} restored, ${_skipped} skipped, ${_failed} failed"
)
if(_failed GREATER 0)
  message(FATAL_ERROR "${_failed} project(s) failed to restore")
endif()
