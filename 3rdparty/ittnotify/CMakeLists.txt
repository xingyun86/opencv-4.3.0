# ----------------------------------------------------------------------------
#  CMake file for Intel ITT API. See root CMakeLists.txt
#
# ----------------------------------------------------------------------------

if(NOT ITT_LIBRARY)
  set(ITT_LIBRARY "ittnotify")
endif()
project(${ITT_LIBRARY} C)

if(NOT WIN32)
  include(CheckLibraryExists)
  if(COMMAND CHECK_LIBRARY_EXISTS)
    CHECK_LIBRARY_EXISTS(dl dlerror "" HAVE_DL_LIBRARY)
  endif()
endif()

ocv_warnings_disable(CMAKE_C_FLAGS -Wimplicit-fallthrough)

ocv_include_directories("${CMAKE_CURRENT_SOURCE_DIR}/include")
set(ITT_INCLUDE_DIRECTORY "${CMAKE_CURRENT_SOURCE_DIR}/include")

set(ITT_PUBLIC_HDRS
    include/ittnotify.h
    include/jitprofiling.h
    include/libittnotify.h
    include/llvm_jit_event_listener.hpp
)
set(ITT_PRIVATE_HDRS
    src/ittnotify/disable_warnings.h
    src/ittnotify/ittnotify_config.h
    src/ittnotify/ittnotify_static.h
    src/ittnotify/ittnotify_types.h
)
set(ITT_SRCS
    src/ittnotify/ittnotify_static.c
    src/ittnotify/jitprofiling.c
)

add_library(${ITT_LIBRARY} STATIC ${ITT_SRCS} ${ITT_PUBLIC_HDRS} ${ITT_PRIVATE_HDRS})

if (MSVC)
	list(APPEND project_name_cflags /W4)
	list(APPEND project_name_defines WIN32_LEAN_AND_MEAN _WIN32_WINNT=0x0501)
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
	
	target_compile_definitions(${ITT_LIBRARY}
							PRIVATE ${project_name_defines}
							)
	target_compile_options(${ITT_LIBRARY}
							PRIVATE ${project_name_cflags}
	)
else()
    set(CMAKE_C_FLAGS "$ENV{CFLAGS} ${CMAKE_C_FLAGS} -fPIC")
    set(CMAKE_CXX_FLAGS "$ENV{CXXFLAGS} ${CMAKE_CXX_FLAGS} -fPIC")
endif(MSVC)
if(NOT WIN32)
  if(HAVE_DL_LIBRARY)
    target_link_libraries(${ITT_LIBRARY} dl)
  endif()
endif()

set_target_properties(${ITT_LIBRARY} PROPERTIES
        OUTPUT_NAME ${ITT_LIBRARY}
        DEBUG_POSTFIX "${OPENCV_DEBUG_POSTFIX}"
        COMPILE_PDB_NAME ${ITT_LIBRARY}
        COMPILE_PDB_NAME_DEBUG "${ITT_LIBRARY}${OPENCV_DEBUG_POSTFIX}"
        ARCHIVE_OUTPUT_DIRECTORY ${3P_LIBRARY_OUTPUT_PATH}
    )

ocv_warnings_disable(CMAKE_C_FLAGS -Wundef -Wsign-compare)

if(ENABLE_SOLUTION_FOLDERS)
  set_target_properties(${ITT_LIBRARY} PROPERTIES FOLDER "3rdparty")
endif()

if(NOT BUILD_SHARED_LIBS)
  ocv_install_target(${ITT_LIBRARY} EXPORT OpenCVModules ARCHIVE DESTINATION ${OPENCV_3P_LIB_INSTALL_PATH} COMPONENT dev)
endif()

ocv_install_3rdparty_licenses(ittnotify src/ittnotify/LICENSE.BSD src/ittnotify/LICENSE.GPL)
