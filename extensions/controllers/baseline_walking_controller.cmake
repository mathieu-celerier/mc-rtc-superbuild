include(${CMAKE_CURRENT_LIST_DIR}/../control/centroidal_control_collection.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../control/force_control_collection.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../planning/baseline_footstep_planner.cmake)
include(${CMAKE_CURRENT_LIST_DIR}/../trajectory/trajectory_collection.cmake)

AddProject(BaseLineWalkingController
  GITHUB isri-aist/BaseLineWalkingController
  GIT_TAG origin/master
  DEPENDS CentroidalControlCollection BaseLineFootstepPlanner ForceControlCollection TrajectoryCollection
)
