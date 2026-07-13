CreateCatkinWorkspace(ID jst-mirai-tactile-demo DIR jst_mirai_tactile_demo_ws CATKIN_BUILD)

AptInstall(
  ros-${ROS_DISTRO}-cv-bridge libncurses5-dev libncursesw5-dev
)

AddCatkinProject(serial
  WORKSPACE jst-mirai-tactile-demo
  GITHUB ThomasDuvinage/serial-ros2
  GIT_TAG origin/master
)

AddProject(HARC_IFBOX
  GITHUB_PRIVATE isri-aist/HARC_IFBOX
  GIT_TAG origin/master
)

AddCatkinProject(tactile_info_framework
  WORKSPACE jst-mirai-tactile-demo
  GITHUB_PRIVATE isri-aist/tactile_info_framework
  GIT_TAG origin/masterbr
  DEPENDS HARC_IFBOX
)

AddProject(tactile_admittance_controller
  GITHUB_PRIVATE isri-aist/tactile-based-explicit-compliance-controller
  GIT_TAG origin/topic/switch-to-explicit-compliance
  DEPENDS mc_rtc tactile_info_framework
)
