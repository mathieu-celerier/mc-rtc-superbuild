AptInstall(libgoogle-glog-dev)
AddProject(
  ceres-solver
  GITHUB ceres-solver/ceres-solver
  GIT_TAG 2.2.0
  CMAKE_ARGS -DBUILD_BENCHMARKS:BOOL=OFF -DBUILD_EXAMPLES:BOOL=OFF -DBUILD_SHARED_LIBS:BOOL=OFF
  SKIP_TEST
)
AddProject(
  mc_force_sensor_calibration_controller
  GITHUB mathieu-celerier/mc_force_sensor_calibration_controller
  GIT_TAG origin/topic/kinova-calib
  DEPENDS mc_rtc ceres-solver
)
