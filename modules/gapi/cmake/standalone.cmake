if("${CMAKE_BUILD_TYPE}" STREQUAL "")
  set(CMAKE_BUILD_TYPE "Release")
endif()

if (NOT TARGET ade )
  find_package(ade 0.1.0 REQUIRED)
endif()

set(FLUID_TARGET fluid)
set(FLUID_ROOT "${CMAKE_CURRENT_LIST_DIR}/../")

file(GLOB FLUID_includes "${FLUID_ROOT}/include/opencv2/*.hpp"
                         "${FLUID_ROOT}/include/opencv2/gapi/g*.hpp"
                         "${FLUID_ROOT}/include/opencv2/gapi/util/*.hpp"
                         "${FLUID_ROOT}/include/opencv2/gapi/own/*.hpp"
                         "${FLUID_ROOT}/include/opencv2/gapi/fluid/*.hpp")
file(GLOB FLUID_sources  "${FLUID_ROOT}/src/api/g*.cpp"
                         "${FLUID_ROOT}/src/compiler/*.cpp"
                         "${FLUID_ROOT}/src/compiler/passes/*.cpp"
                         "${FLUID_ROOT}/src/executor/*.cpp"
                         "${FLUID_ROOT}/src/backends/fluid/*.cpp"
                         "${FLUID_ROOT}/src/backends/common/*.cpp")

add_library(${FLUID_TARGET} STATIC ${FLUID_includes} ${FLUID_sources})

target_include_directories(${FLUID_TARGET}
  PUBLIC          $<BUILD_INTERFACE:${FLUID_ROOT}/include>
  PRIVATE         ${FLUID_ROOT}/src)

target_compile_definitions(${FLUID_TARGET} PUBLIC GAPI_STANDALONE
# This preprocessor definition resolves symbol clash when
# standalone fluid meets gapi ocv module in one application
                                           PUBLIC cv=fluidcv)

set_target_properties(${FLUID_TARGET} PROPERTIES POSITION_INDEPENDENT_CODE True)
set_property(TARGET ${FLUID_TARGET} PROPERTY CXX_STANDARD 11)

if(MSVC)
  target_compile_options(${FLUID_TARGET} PUBLIC "/wd4251")
  target_compile_options(${FLUID_TARGET} PUBLIC "/wd4275")
  target_compile_definitions(${FLUID_TARGET} PRIVATE _CRT_SECURE_NO_DEPRECATE)
  # Disable obsollete warning C4503 popping up on MSVC <<2017
  # https://docs.microsoft.com/en-us/cpp/error-messages/compiler-warnings/compiler-warning-level-1-c4503?view=vs-2019
  set_target_properties(${FLUID_TARGET} PROPERTIES COMPILE_FLAGS "/wd4503")
endif()

if (MSVC)
	list(APPEND project_name_cflags /W4)
	list(APPEND project_name_defines WIN32_LEAN_AND_MEAN _WIN32_WINNT=0x0501 -DMAGICKCORE_WINDOWS_SUPPORT=1 -DMAGICKCORE_HDRI_ENABLE=1 -DMAGICKCORE_QUANTUM_DEPTH=16)
	MESSAGE(STATUS "CMAKE_BUILD_TYPE=" ${CMAKE_BUILD_TYPE})

	set(CompilerFlags
		CMAKE_CXX_FLAGS
		CMAKE_CXX_FLAGS_DEBUG
		CMAKE_CXX_FLAGS_RELEASE
		CMAKE_C_FLAGS
		CMAKE_C_FLAGS_DEBUG
		CMAKE_C_FLAGS_RELEASE
		)
	foreach(CompilerFlag ${CompilerFlags})
		string(REPLACE "/MD" "/MT" ${CompilerFlag} "${${CompilerFlag}}")
	endforeach()
	
	target_compile_definitions(${FLUID_TARGET}
							PRIVATE ${project_name_defines}
							)
	target_compile_options(${FLUID_TARGET}
							PRIVATE ${project_name_cflags}
	)
else()
    set(CMAKE_C_FLAGS "$ENV{CFLAGS} ${CMAKE_C_FLAGS} -fPIC")
    set(CMAKE_CXX_FLAGS "$ENV{CXXFLAGS} ${CMAKE_CXX_FLAGS} -fPIC")
endif(MSVC)
target_link_libraries(${FLUID_TARGET} PRIVATE ade)
