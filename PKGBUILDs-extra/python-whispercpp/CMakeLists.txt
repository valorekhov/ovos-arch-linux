cmake_minimum_required(VERSION 3.4...3.18)
project(pywhispercpp)

find_library(WHISPER_CPP_LIB libwhisper.so)

if (WHISPER_CPP_LIB)
    message(STATUS "whisper.cpp library found")

    # Add the include directory to the include paths
    include_directories(${WHISPER_CPP_INCLUDE_DIR})
    
else()
    message(WARNING "whisper.cpp library not found")
endif()

add_subdirectory(pybind11)

# -----------------
pybind11_add_module(_pywhispercpp
	${CPP_FILES}
	${C_FILES}
	src/main.cpp
)

# EXAMPLE_VERSION_INFO is defined by setup.py and passed into the C++ code as a
# define (VERSION_INFO) here.
target_compile_definitions(_pywhispercpp
                           PRIVATE VERSION_INFO=${EXAMPLE_VERSION_INFO})