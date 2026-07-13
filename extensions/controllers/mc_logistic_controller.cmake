set(EXTENSIONS_DIR ${CMAKE_CURRENT_LIST_DIR}/../superbuild-extensions)
include(${EXTENSIONS_DIR}/controllers/BaseLineWalkingController.cmake)

AptInstall(ros-${ROS_DISTRO}-tf2-eigen)

AddProject(mc_logistic_controller
  GITHUB_PRIVATE mathieu-celerier/mc_logistic_controller
  GIT_TAG origin/devel
  CMAKE_ARGS -DINSTALL_MUJOCO_OBJECTS=${WITH_MC_MUJOCO}
  DEPENDS mc_rtc ${MUJOCO_LIBRARY} BaseLineWalkingController ismpc_walking tactile_admittance_controller
)
