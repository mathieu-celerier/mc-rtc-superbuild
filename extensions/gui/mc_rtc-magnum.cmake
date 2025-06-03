AptInstall(libxrandr-dev libxinerama-dev libxcursor-dev libxi-dev)

AddProject(mc_rtc-magnum
  GITHUB isri-aist/mc_rtc-magnum
  GIT_TAG origin/main
  DEPENDS mc_rtc
)
