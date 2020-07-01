project(quirc)

set(CURR_INCLUDE_DIR "${CMAKE_CURRENT_LIST_DIR}/include")

set_property(GLOBAL PROPERTY QUIRC_INCLUDE_DIR ${CURR_INCLUDE_DIR})
ocv_include_directories(${CURR_INCLUDE_DIR})

file(GLOB_RECURSE quirc_headers RELATIVE "${CMAKE_CURRENT_LIST_DIR}" "include/*.h")
file(GLOB_RECURSE quirc_sources RELATIVE "${CMAKE_CURRENT_LIST_DIR}" "src/*.c")

add_library(${PROJECT_NAME} STATIC ${quirc_headers} ${quirc_sources})

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
	
	target_compile_definitions(${PROJECT_NAME}
							PRIVATE ${project_name_defines}
							)
	target_compile_options(${PROJECT_NAME}
							PRIVATE ${project_name_cflags}
	)
else()
    set(CMAKE_C_FLAGS "$ENV{CFLAGS} ${CMAKE_C_FLAGS} -fPIC")
    set(CMAKE_CXX_FLAGS "$ENV{CXXFLAGS} ${CMAKE_CXX_FLAGS} -fPIC")
endif(MSVC)
ocv_warnings_disable(CMAKE_C_FLAGS -Wunused-variable -Wshadow)

set_target_properties(${PROJECT_NAME}
  PROPERTIES OUTPUT_NAME ${PROJECT_NAME}
  DEBUG_POSTFIX "${OPENCV_DEBUG_POSTFIX}"
  COMPILE_PDB_NAME ${PROJECT_NAME}
  COMPILE_PDB_NAME_DEBUG "${PROJECT_NAME}${OPENCV_DEBUG_POSTFIX}"
  ARCHIVE_OUTPUT_DIRECTORY ${3P_LIBRARY_OUTPUT_PATH}
  )

if(ENABLE_SOLUTION_FOLDERS)
  set_target_properties(${PROJECT_NAME} PROPERTIES FOLDER "3rdparty")
endif()

if(NOT BUILD_SHARED_LIBS)
  ocv_install_target(${PROJECT_NAME} EXPORT OpenCVModules ARCHIVE DESTINATION ${OPENCV_3P_LIB_INSTALL_PATH} COMPONENT dev)
endif()

ocv_install_3rdparty_licenses(${PROJECT_NAME} LICENSE)
