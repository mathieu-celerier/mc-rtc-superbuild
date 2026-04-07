option(WITH_RHPS1 "Build RHPS1 support" OFF)

if(NOT WITH_RHPS1)
  return()
endif()

AddCatkinProject(
  rhps1_description
  GITHUB_PRIVATE isri-aist/rhps1_description
  GIT_TAG origin/master
  WORKSPACE data_ws
  CMAKE_ARGS ${MC_RTC_ROS_OPTION}
)

AddProject(
  mc_rhps1
  GITHUB_PRIVATE mathieu-celerier/mc_rhps1
  GIT_TAG origin/topic/add-rotor-inertia
  DEPENDS rhps1_description mc_rtc
)
