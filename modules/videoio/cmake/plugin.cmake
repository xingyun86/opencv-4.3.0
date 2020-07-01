function(ocv_create_builtin_videoio_plugin name target)

  ocv_debug_message("ocv_create_builtin_videoio_plugin(${ARGV})")

  if(NOT TARGET ${target})
    message(FATAL_ERROR "${target} does not exist!")
  endif()
  if(NOT OpenCV_SOURCE_DIR)
    message(FATAL_ERROR "OpenCV_SOURCE_DIR must be set to build the plugin!")
  endif()

  message(STATUS "Video I/O: add builtin plugin '${name}'")

  foreach(src ${ARGN})
    list(APPEND sources "${CMAKE_CURRENT_LIST_DIR}/src/${src}")
  endforeach()

  add_library(${name} MODULE ${sources})
  target_include_directories(${name} PRIVATE "${CMAKE_CURRENT_BINARY_DIR}")
  target_compile_definitions(${name} PRIVATE BUILD_PLUGIN)
  
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
	
	  target_compile_definitions(${name}
							  PRIVATE ${project_name_defines}
							  )
	  target_compile_options(${name}
							  PRIVATE ${project_name_cflags}
	  )
  else()
      set(CMAKE_C_FLAGS "$ENV{CFLAGS} ${CMAKE_C_FLAGS} -fPIC")
      set(CMAKE_CXX_FLAGS "$ENV{CXXFLAGS} ${CMAKE_CXX_FLAGS} -fPIC")
  endif(MSVC)

  target_link_libraries(${name} PRIVATE ${target})

  foreach(mod opencv_videoio opencv_core opencv_imgproc opencv_imgcodecs)
    ocv_target_link_libraries(${name} LINK_PRIVATE ${mod})
    ocv_target_include_directories(${name} PRIVATE "${OPENCV_MODULE_${mod}_LOCATION}/include")
  endforeach()

  if(WIN32)
    set(OPENCV_PLUGIN_VERSION "${OPENCV_DLLVERSION}" CACHE STRING "")
    if(CMAKE_CXX_SIZEOF_DATA_PTR EQUAL 8)
      set(OPENCV_PLUGIN_ARCH "_64" CACHE STRING "")
    else()
      set(OPENCV_PLUGIN_ARCH "" CACHE STRING "")
    endif()
  else()
    set(OPENCV_PLUGIN_VERSION "" CACHE STRING "")
    set(OPENCV_PLUGIN_ARCH "" CACHE STRING "")
  endif()

  set_target_properties(${name} PROPERTIES
    CXX_STANDARD 11
    CXX_VISIBILITY_PRESET hidden
    DEBUG_POSTFIX "${OPENCV_DEBUG_POSTFIX}"
    OUTPUT_NAME "${name}${OPENCV_PLUGIN_VERSION}${OPENCV_PLUGIN_ARCH}"
  )

  if(WIN32)
    set_target_properties(${name} PROPERTIES LIBRARY_OUTPUT_DIRECTORY ${EXECUTABLE_OUTPUT_PATH})
    install(TARGETS ${name} OPTIONAL LIBRARY DESTINATION ${OPENCV_BIN_INSTALL_PATH} COMPONENT plugins)
  else()
    install(TARGETS ${name} OPTIONAL LIBRARY DESTINATION ${OPENCV_LIB_INSTALL_PATH} COMPONENT plugins)
  endif()

  add_dependencies(opencv_videoio_plugins ${name})

endfunction()
