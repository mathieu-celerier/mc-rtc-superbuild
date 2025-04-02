AddGitSource(GITLAB https://gitlab.com/)

AptInstall(ros-noetic-soem)
AptInstall(ros-noetic-ethercat-grant)

AddCatkinProject(bota_driver
  WORKSPACE data_ws
  GITLAB botasys/bota_driver
  GIT_TAG origin/master
)
