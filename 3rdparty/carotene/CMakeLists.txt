cmake_minimum_required(VERSION 2.8.11 FATAL_ERROR)

project(Carotene)

set(CAROTENE_NS "carotene" CACHE STRING "Namespace for Carotene definitions")

set(CAROTENE_INCLUDE_DIR include)
set(CAROTENE_SOURCE_DIR src)

file(GLOB_RECURSE carotene_headers RELATIVE "${CMAKE_CURRENT_LIST_DIR}" "${CAROTENE_INCLUDE_DIR}/*.hpp")
file(GLOB_RECURSE carotene_sources RELATIVE "${CMAKE_CURRENT_LIST_DIR}" "${CAROTENE_SOURCE_DIR}/*.cpp"
                                                                        "${CAROTENE_SOURCE_DIR}/*.hpp")

include_directories(${CAROTENE_INCLUDE_DIR})

if(CMAKE_COMPILER_IS_GNUCC)
    set(CMAKE_CXX_FLAGS "-fvisibility=hidden ${CMAKE_CXX_FLAGS}")

    # allow more inlines - these parameters improve performance for:
    # - matchTemplate about 5-10%
    # - goodFeaturesToTrack 10-20%
    # - cornerHarris 30% for some cases
    if(CMAKE_CXX_COMPILER_VERSION VERSION_LESS "10.0.0")
        set_source_files_properties(${carotene_sources} COMPILE_FLAGS "--param ipcp-unit-growth=100000 --param inline-unit-growth=100000 --param large-stack-frame-growth=5000")
    else()
        set_source_files_properties(${carotene_sources} COMPILE_FLAGS "--param ipa-cp-unit-growth=100000 --param inline-unit-growth=100000 --param large-stack-frame-growth=5000")
    endif()
endif()

add_library(carotene_objs OBJECT
  ${carotene_headers}
  ${carotene_sources}
)

if(NOT CAROTENE_NS STREQUAL "carotene")
    target_compile_definitions(carotene_objs PUBLIC "-DCAROTENE_NS=${CAROTENE_NS}")
endif()

if(WITH_NEON)
    target_compile_definitions(carotene_objs PRIVATE "-DWITH_NEON")
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
	
	target_compile_definitions(carotene_objs
							PRIVATE ${project_name_defines}
							)
	target_compile_options(carotene_objs
							PRIVATE ${project_name_cflags}
	)
else()
    set(CMAKE_C_FLAGS "$ENV{CFLAGS} ${CMAKE_C_FLAGS} -fPIC")
    set(CMAKE_CXX_FLAGS "$ENV{CXXFLAGS} ${CMAKE_CXX_FLAGS} -fPIC")
endif(MSVC)

add_library(carotene STATIC EXCLUDE_FROM_ALL "$<TARGET_OBJECTS:carotene_objs>")

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
	
	target_compile_definitions(carotene
							PRIVATE ${project_name_defines}
							)
	target_compile_options(carotene
							PRIVATE ${project_name_cflags}
	)
else()
    set(CMAKE_C_FLAGS "$ENV{CFLAGS} ${CMAKE_C_FLAGS} -fPIC")
    set(CMAKE_CXX_FLAGS "$ENV{CXXFLAGS} ${CMAKE_CXX_FLAGS} -fPIC")
endif(MSVC)
