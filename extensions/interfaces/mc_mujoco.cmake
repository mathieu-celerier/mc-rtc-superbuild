include(${CMAKE_CURRENT_LIST_DIR}/../simulation/MuJoCo.cmake)

AptInstall(libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev libglew-dev)

AddProject(mc_mujoco
  GITHUB_PRIVATE mathieu-celerier/mc_mujoco
  GIT_TAG origin/main
  CMAKE_ARGS -DMUJOCO_ROOT_DIR=${MUJOCO_ROOT_DIR}
  DEPENDS mc_rtc
)

if(WITH_HRP5)
  AddProject(hrp5p_mj_description
    GITHUB_PRIVATE isri-aist/hrp5p_mj_description
    GIT_TAG origin/main
    DEPENDS mc_mujoco
  )
endif()

if(WITH_HRP4CR)
  AddProject(hrp4cr_mj_description
    GITHUB_PRIVATE isri-aist/hrp4cr_mj_description
    GIT_TAG origin/main
    DEPENDS mc_mujoco
  )
endif()

if(WITH_Kinova)
  if(WITH_ROS_SUPPORT)
    function(AddKinovaMujocoModel)
      AddProject(kinova_mj_description
        GITHUB_PRIVATE mathieu-celerier/kinova_mj_description
        GIT_TAG origin/bota_ft_sensor_w_DS4_adapter
        DEPENDS mc_mujoco mc_kinova
      )
    endfunction()
    cmake_language(DEFER CALL AddKinovaMujocoModel)
  endif()
endif()
