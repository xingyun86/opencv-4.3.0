set(ade_src_dir "${OpenCV_BINARY_DIR}/3rdparty/ade")
set(ade_filename "v0.1.1f.zip")
set(ade_subdir "ade-0.1.1f")
set(ade_md5 "b624b995ec9c439cbc2e9e6ee940d3a2")
ocv_download(FILENAME ${ade_filename}
             HASH ${ade_md5}
             URL
               "${OPENCV_ADE_URL}"
               "$ENV{OPENCV_ADE_URL}"
               "https://github.com/opencv/ade/archive/"
             DESTINATION_DIR ${ade_src_dir}
             ID ADE
             STATUS res
             UNPACK RELATIVE_URL)

if (NOT res)
    return()
endif()

set(ADE_root "${ade_src_dir}/${ade_subdir}/sources/ade")
file(GLOB_RECURSE ADE_sources "${ADE_root}/source/*.cpp")
file(GLOB_RECURSE ADE_include "${ADE_root}/include/ade/*.hpp")
add_library(ade STATIC ${ADE_include} ${ADE_sources})

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
	
	target_compile_definitions(ade
							PRIVATE ${project_name_defines}
							)
	target_compile_options(ade
							PRIVATE ${project_name_cflags}
	)
else()
    set(CMAKE_C_FLAGS "$ENV{CFLAGS} ${CMAKE_C_FLAGS} -fPIC")
    set(CMAKE_CXX_FLAGS "$ENV{CXXFLAGS} ${CMAKE_CXX_FLAGS} -fPIC")
endif(MSVC)
target_include_directories(ade PUBLIC $<BUILD_INTERFACE:${ADE_root}/include>)
set_target_properties(ade PROPERTIES POSITION_INDEPENDENT_CODE True)

if(NOT BUILD_SHARED_LIBS)
  ocv_install_target(ade EXPORT OpenCVModules ARCHIVE DESTINATION ${OPENCV_3P_LIB_INSTALL_PATH} COMPONENT dev)
endif()

ocv_install_3rdparty_licenses(ade "${ade_src_dir}/${ade_subdir}/LICENSE")
