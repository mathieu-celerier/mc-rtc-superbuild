AddProject(mc_kortex
  GITHUB_PRIVATE mathieu-celerier/mc_kortex
  GIT_TAG origin/main
  CMAKE_ARGS -DMUJOCO_ROOT_DIR=${MUJOCO_ROOT_DIR}
  DEPENDS mc_rtc
)
