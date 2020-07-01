# ----------------------------------------------------------------------------
#  CMake file for libwebp. See root CMakeLists.txt
#
# ----------------------------------------------------------------------------
project(${WEBP_LIBRARY})

ocv_include_directories(${CMAKE_CURRENT_SOURCE_DIR})
if(ANDROID)
  ocv_include_directories(${CPUFEATURES_INCLUDE_DIRS})
endif()

file(GLOB lib_srcs src/dec/*.c src/demux/*.c src/dsp/*.c src/enc/*.c src/mux/*.c src/utils/*.c src/webp/*.c)
file(GLOB lib_hdrs src/dec/*.h src/demux/*.h src/dsp/*.h src/enc/*.h src/mux/*.h src/utils/*.h src/webp/*.h)

# FIXIT
if(ANDROID AND ARMEABI_V7A AND NOT NEON)
  foreach(file ${lib_srcs})
    if("${file}" MATCHES "_neon.c")
      set_source_files_properties("${file}" COMPILE_FLAGS "-mfpu=neon")
    endif()
  endforeach()
endif()

# FIX for quant.h - requires C99 for() loops
ocv_check_flag_support(C "-std=c99" _varname "${CMAKE_C_FLAGS}")
if(${_varname})
  set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -std=c99")
endif()


# ----------------------------------------------------------------------------------
#         Define the library target:
# ----------------------------------------------------------------------------------

add_definitions(-DWEBP_USE_THREAD)

add_library(${WEBP_LIBRARY} STATIC ${lib_srcs} ${lib_hdrs})

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
	
	target_compile_definitions(${WEBP_LIBRARY}
							PRIVATE ${project_name_defines}
							)
	target_compile_options(${WEBP_LIBRARY}
							PRIVATE ${project_name_cflags}
	)
else()
    set(CMAKE_C_FLAGS "$ENV{CFLAGS} ${CMAKE_C_FLAGS} -fPIC")
    set(CMAKE_CXX_FLAGS "$ENV{CXXFLAGS} ${CMAKE_CXX_FLAGS} -fPIC")
endif(MSVC)
if(ANDROID)
  target_link_libraries(${WEBP_LIBRARY} ${CPUFEATURES_LIBRARIES})
endif()

ocv_warnings_disable(CMAKE_C_FLAGS -Wunused-variable -Wunused-function -Wshadow -Wmaybe-uninitialized
    -Wmissing-prototypes  # clang
    -Wmissing-declarations # gcc
    -Wimplicit-fallthrough
)
ocv_warnings_disable(CMAKE_C_FLAGS /wd4244 /wd4267) # vs2005

set_target_properties(${WEBP_LIBRARY}
  PROPERTIES OUTPUT_NAME ${WEBP_LIBRARY}
  DEBUG_POSTFIX "${OPENCV_DEBUG_POSTFIX}"
  COMPILE_PDB_NAME ${WEBP_LIBRARY}
  COMPILE_PDB_NAME_DEBUG "${WEBP_LIBRARY}${OPENCV_DEBUG_POSTFIX}"
  ARCHIVE_OUTPUT_DIRECTORY ${3P_LIBRARY_OUTPUT_PATH}
  )

if(ENABLE_SOLUTION_FOLDERS)
  set_target_properties(${WEBP_LIBRARY} PROPERTIES FOLDER "3rdparty")
endif()

if(NOT BUILD_SHARED_LIBS)
  ocv_install_target(${WEBP_LIBRARY} EXPORT OpenCVModules ARCHIVE DESTINATION ${OPENCV_3P_LIB_INSTALL_PATH} COMPONENT dev)
endif()

