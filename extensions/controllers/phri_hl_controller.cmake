include(${CMAKE_CURRENT_LIST_DIR}/../catkin_projects/phri_hl_exp_ros_msg.cmake)

AddProject(phri_hl_controller
  GITHUB_PRIVATE mathieu-celerier/PHRI_HL_controller
	GIT_TAG origin/kinova
	DEPENDS mc_rtc
)
