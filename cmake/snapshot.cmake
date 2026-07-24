# Superbuild source snapshots
# ============================
#
# A snapshot records the exact commit (and origin remote) of every source project so
# that a full multi-repository state can be committed into the superbuild repository and
# reproduced later (for a demonstration, a paper, a specific piece of work, ...).
#
# Snapshots live in `snapshots/<name>.cmake` and are selected at configure time with
# `-DSNAPSHOT=<name>`. Each file simply sets, for every project:
#
#   set(MC_RTC_SUPERBUILD_SNAPSHOT_<NAME>_GIT_TAG <commit-sha>)
#   set(MC_RTC_SUPERBUILD_SNAPSHOT_<NAME>_REMOTE  <origin-url>)
#
# `AddProject` consults these values with the precedence:
#   command-line MC_RTC_SUPERBUILD_OVERRIDE_* (CI) > snapshot > declared > origin/main
# Because a pinned commit is not an `origin/*` ref it is treated as a fixed tag and is
# therefore immune to the `update` target (see cmake/scripts/update-project.cmake).
#
# Two targets are provided:
#   * save-snapshot    write snapshots/<SNAPSHOT>.cmake from the current on-disk state
#   * restore-snapshot check out the recorded commits (and remotes) for every project

# Include the selected snapshot file. Must be called BEFORE any AddProject call so the
# pinned values are visible while projects are declared.
function(LoadSnapshot)
  if("${SNAPSHOT}" STREQUAL "")
    return()
  endif()
  set(_snapshot_file "${PROJECT_SOURCE_DIR}/snapshots/${SNAPSHOT}.cmake")
  if(NOT EXISTS "${_snapshot_file}")
    set(_msg "SNAPSHOT is set to '${SNAPSHOT}' but ${_snapshot_file} does not exist.")
    file(GLOB _available "${PROJECT_SOURCE_DIR}/snapshots/*.cmake")
    if(_available)
      string(APPEND _msg "\nAvailable snapshots:")
      foreach(_s ${_available})
        cmake_path(GET _s STEM _name)
        string(APPEND _msg "\n  - ${_name}")
      endforeach()
    endif()
    message(FATAL_ERROR "${_msg}")
  endif()
  message(STATUS "Loading source snapshot '${SNAPSHOT}' from ${_snapshot_file}")
  include("${_snapshot_file}")
  # Re-export the values loaded by the (function-scoped) include to the caller scope so
  # AddProject can see them.
  get_cmake_property(_vars VARIABLES)
  foreach(_v ${_vars})
    if(_v MATCHES "^MC_RTC_SUPERBUILD_SNAPSHOT_.*_(GIT_TAG|REMOTE)$")
      set(${_v}
          "${${_v}}"
          PARENT_SCOPE
      )
    endif()
  endforeach()
endfunction()

# Generate the project manifest and create the save/restore targets. Must be called
# AFTER every project has been declared (registry is complete).
function(SetupSnapshotTargets)
  get_property(_projects GLOBAL PROPERTY MC_RTC_SUPERBUILD_PROJECTS)
  set(_manifest_lines "")
  foreach(_name ${_projects})
    get_property(_src GLOBAL PROPERTY MC_RTC_SUPERBUILD_PROJECT_${_name}_SOURCE_DIR)
    string(APPEND _manifest_lines "${_name}|${_src}\n")
  endforeach()
  set(_manifest "${CMAKE_BINARY_DIR}/snapshot-manifest.txt")
  file(
    GENERATE
    OUTPUT "${_manifest}"
    CONTENT "${_manifest_lines}"
  )

  set(_scripts "${CMAKE_CURRENT_FUNCTION_LIST_DIR}/scripts")

  add_custom_target(
    save-snapshot
    COMMAND
      "${CMAKE_COMMAND}" -DSNAPSHOT=${SNAPSHOT} -DMANIFEST=${_manifest}
      -DOUTPUT=${PROJECT_SOURCE_DIR}/snapshots/${SNAPSHOT}.cmake -P
      "${_scripts}/save-snapshot.cmake"
    COMMENT "Saving source snapshot '${SNAPSHOT}'"
    VERBATIM
  )

  add_custom_target(
    restore-snapshot
    COMMAND
      "${CMAKE_COMMAND}" -DSNAPSHOT=${SNAPSHOT} -DMANIFEST=${_manifest}
      -DSNAPSHOT_FILE=${PROJECT_SOURCE_DIR}/snapshots/${SNAPSHOT}.cmake -P
      "${_scripts}/restore-snapshot.cmake"
    COMMENT "Restoring source snapshot '${SNAPSHOT}'"
    VERBATIM
  )
  add_dependencies(restore-snapshot clone)
endfunction()
