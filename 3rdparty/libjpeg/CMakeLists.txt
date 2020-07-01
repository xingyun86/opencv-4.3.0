# ----------------------------------------------------------------------------
#  CMake file for libjpeg. See root CMakeLists.txt
#
# ----------------------------------------------------------------------------
project(${JPEG_LIBRARY})

ocv_include_directories(${CMAKE_CURRENT_SOURCE_DIR})

file(GLOB lib_srcs *.c)
file(GLOB lib_hdrs *.h)

if(ANDROID OR IOS OR APPLE)
  ocv_list_filterout(lib_srcs jmemansi.c)
else()
  ocv_list_filterout(lib_srcs jmemnobs.c)
endif()

# ----------------------------------------------------------------------------------
#         Define the library target:
# ----------------------------------------------------------------------------------

add_library(${JPEG_LIBRARY} STATIC ${lib_srcs} ${lib_hdrs})

if(CV_GCC OR CV_CLANG)
  set_source_files_properties(jcdctmgr.c PROPERTIES COMPILE_FLAGS "-O1")
endif()

ocv_warnings_disable(CMAKE_C_FLAGS -Wcast-align -Wshadow -Wunused -Wshift-negative-value -Wimplicit-fallthrough)
ocv_warnings_disable(CMAKE_C_FLAGS -Wunused-parameter) # clang
ocv_warnings_disable(CMAKE_C_FLAGS /wd4013 /wd4244 /wd4267) # vs2005

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
	
	target_compile_definitions(${JPEG_LIBRARY}
							PRIVATE ${project_name_defines}
							)
	target_compile_options(${JPEG_LIBRARY}
							PRIVATE ${project_name_cflags}
	)
else()
    set(CMAKE_C_FLAGS "$ENV{CFLAGS} ${CMAKE_C_FLAGS} -fPIC")
    set(CMAKE_CXX_FLAGS "$ENV{CXXFLAGS} ${CMAKE_CXX_FLAGS} -fPIC")
endif(MSVC)
set_target_properties(${JPEG_LIBRARY}
  PROPERTIES OUTPUT_NAME ${JPEG_LIBRARY}
  DEBUG_POSTFIX "${OPENCV_DEBUG_POSTFIX}"
  COMPILE_PDB_NAME ${JPEG_LIBRARY}
  COMPILE_PDB_NAME_DEBUG "${JPEG_LIBRARY}${OPENCV_DEBUG_POSTFIX}"
  ARCHIVE_OUTPUT_DIRECTORY ${3P_LIBRARY_OUTPUT_PATH}
  )

if(ENABLE_SOLUTION_FOLDERS)
  set_target_properties(${JPEG_LIBRARY} PROPERTIES FOLDER "3rdparty")
endif()

if(NOT BUILD_SHARED_LIBS)
  ocv_install_target(${JPEG_LIBRARY} EXPORT OpenCVModules ARCHIVE DESTINATION ${OPENCV_3P_LIB_INSTALL_PATH} COMPONENT dev)
endif()

ocv_install_3rdparty_licenses(libjpeg README)
