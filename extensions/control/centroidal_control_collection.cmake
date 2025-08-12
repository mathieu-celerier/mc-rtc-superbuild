include(${CMAKE_CURRENT_LIST_DIR}/force_control_collection.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/nmpc.cmake)

AddProject(CentroidalControlCollection
  GITHUB isri-aist/CentroidalControlCollection
  GIT_TAG origin/master
  DEPENDS ForceControlCollection NMPC
)

