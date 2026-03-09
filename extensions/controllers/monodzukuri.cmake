AptInstall(libglu1-mesa-dev freeglut3-dev libglfw3-dev)

AddProject(monodzukuri_controller
	GITHUB_PRIVATE bastien-muraccioli/monodzukuri2024_kinova_demo
  GIT_TAG origin/rss2025_new_implementation
	DEPENDS mc_rtc mc_ros_force_sensor
) 
