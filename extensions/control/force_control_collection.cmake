include(${CMAKE_CURRENT_LIST_DIR}/../solvers/qpsolver_collection.cmake)

AddProject(ForceControlCollection
  GITHUB isri-aist/ForceControlCollection
  GIT_TAG origin/master
  DEPENDS QpSolverCollection mc_rtc
)
