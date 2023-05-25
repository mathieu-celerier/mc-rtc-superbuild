option(WITH_Kinova "Build Kinova support" OFF)

if(NOT WITH_Kinova)
	return()
endif()

AddProject(mc_kinova
	GITHUB mathieu-celerier/mc_kinova
	GIT_TAG origin/main
	DEPENDS  mc_rtc
)
