macro(add_backend backend_id cond_var)
  if(${cond_var})
    include("${CMAKE_CURRENT_LIST_DIR}/detect_${backend_id}.cmake")
  endif()
endmacro()

function(ocv_add_external_target name inc link def)
  if(BUILD_SHARED_LIBS)
    set(imp IMPORTED)
  endif()
  add_library(ocv.3rdparty.${name} INTERFACE ${imp})
  
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
	
	  #target_compile_definitions(ocv.3rdparty.${name}
		#					  PRIVATE ${project_name_defines}
		#					  )
	  #target_compile_options(ocv.3rdparty.${name}
		#					  PRIVATE ${project_name_cflags}
	  #)
  else()
      set(CMAKE_C_FLAGS "$ENV{CFLAGS} ${CMAKE_C_FLAGS} -fPIC")
      set(CMAKE_CXX_FLAGS "$ENV{CXXFLAGS} ${CMAKE_CXX_FLAGS} -fPIC")
  endif(MSVC)

  set_target_properties(ocv.3rdparty.${name} PROPERTIES
    INTERFACE_INCLUDE_DIRECTORIES "${inc}"
    INTERFACE_SYSTEM_INCLUDE_DIRECTORIES "${inc}"
    INTERFACE_LINK_LIBRARIES "${link}"
    INTERFACE_COMPILE_DEFINITIONS "${def}")
  if(NOT BUILD_SHARED_LIBS)
    install(TARGETS ocv.3rdparty.${name} EXPORT OpenCVModules)
  endif()
endfunction()

add_backend("ffmpeg" WITH_FFMPEG)
add_backend("gstreamer" WITH_GSTREAMER)
add_backend("v4l" WITH_V4L)

add_backend("aravis" WITH_ARAVIS)
add_backend("dc1394" WITH_1394)
add_backend("gphoto" WITH_GPHOTO2)
add_backend("msdk" WITH_MFX)
add_backend("openni2" WITH_OPENNI2)
add_backend("pvapi" WITH_PVAPI)
add_backend("realsense" WITH_LIBREALSENSE)
add_backend("ximea" WITH_XIMEA)
add_backend("xine" WITH_XINE)

add_backend("avfoundation" WITH_AVFOUNDATION)
add_backend("ios" WITH_CAP_IOS)

add_backend("dshow" WITH_DSHOW)
add_backend("msmf" WITH_MSMF)

add_backend("android_mediandk" WITH_ANDROID_MEDIANDK)
