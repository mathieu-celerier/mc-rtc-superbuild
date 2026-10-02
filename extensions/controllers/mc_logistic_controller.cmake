set(EXTENSIONS_DIR ${CMAKE_CURRENT_LIST_DIR}/../superbuild-extensions)
# blasfeo master does not build kernel_sgemv_4_lib.c with CMake since SGEMV
# support was added, leaving undefined symbols in libblasfeo.so
set(MC_RTC_SUPERBUILD_OVERRIDE_blasfeo_GIT_TAG 0.1.4.3)

# TestDdpSingleRigidBody.PlanOnce currently fails, which prevents the install.
# Define the project here (same source as superbuild-extensions) without tests
include(${EXTENSIONS_DIR}/control/ForceControlCollection.cmake)
include(${EXTENSIONS_DIR}/control/NMPC.cmake)
AddProject(CentroidalControlCollection
  GITHUB isri-aist/CentroidalControlCollection
  GIT_TAG origin/master
  DEPENDS ForceControlCollection NMPC
  SKIP_TEST
)

# BaseLineWalkingController tests cannot be used in a ROS 2 environment:
# - the test executables link against the older libosqp.so shipped in
#   /opt/ros/${ROS_DISTRO}/lib (found first through -rpath-link)
# - test_controller runs fine but segfaults at exit in the mc_rtc ROS plugin
# Define the project here (same source as superbuild-extensions) without tests
include(${EXTENSIONS_DIR}/planning/BaseLineFootstepPlanner.cmake)
include(${EXTENSIONS_DIR}/trajectory/TrajectoryCollection.cmake)
set(BASELINE_WALKING_CONTROLLER_CMAKE_ARGS "")
if(WITH_ROS_SUPPORT AND "$ENV{ROS_VERSION}" EQUAL 2)
  set(BASELINE_WALKING_CONTROLLER_CMAKE_ARGS CMAKE_ARGS -DUSE_ROS2=ON)
endif()
AddProject(BaseLineWalkingController
  GITHUB isri-aist/BaseLineWalkingController
  GIT_TAG origin/master
  DEPENDS CentroidalControlCollection BaseLineFootstepPlanner ForceControlCollection TrajectoryCollection
  ${BASELINE_WALKING_CONTROLLER_CMAKE_ARGS}
  SKIP_TEST
)

AptInstall(ros-${ROS_DISTRO}-tf2-eigen)

AddProject(mc_logistic_controller
  GITHUB_PRIVATE mathieu-celerier/mc_logistic_controller
  GIT_TAG origin/devel
  CMAKE_ARGS -DINSTALL_MUJOCO_OBJECTS=ON
  DEPENDS mc_rtc mc_mujoco BaseLineWalkingController ismpc_walking tactile_admittance_controller
)
