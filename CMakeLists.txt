# Copyright: 2014 iCub Facility, Istituto Italiano di Tecnologia
# Author: Francesco Giovannini
# CopyPolicy: Released under the terms of the GNU GPL v2.0.
# 

# ###########################################################################
# The project root CMakeLists.
# ###########################################################################

# ###########################################################################
# Project details
# ###########################################################################
cmake_minimum_required(VERSION 2.6)
set(PROJECTNAME IAITableTopController)
project(${PROJECTNAME})

# Project Version
set(PROJECT_VERSION_MAJOR 1)
set(PROJECT_VERSION_MINOR 0)
 
set(PROJECT_VERSION ${PROJECT_VERSION_MAJOR}.${PROJECT_VERSION_MINOR})
set(EXECUTABLE_OUTPUT_PATH ${PROJECT_BINARY_DIR}/bin)      # Set build path
set(LIBRARY_OUTPUT_PATH ${PROJECT_BINARY_DIR}/lib)         # Set lib path

# Check build type
if(NOT CMAKE_BUILD_TYPE)
    MESSAGE(STATUS "No build type specified. Defaulting to Release.")
    set(CMAKE_BUILD_TYPE Release)
endif(NOT CMAKE_BUILD_TYPE)
# Add flags
MESSAGE(STATUS "Compiling in ${CMAKE_BUILD_TYPE} mode.")
if(CMAKE_BUILD_TYPE MATCHES Debug)
    MESSAGE(STATUS "Adding debug flags to compiler.")
    set(CMAKE_CXX_FLAGS_DEBUG "${CMAKE_CXX_FLAGS_DEBUG} -Wall")
else(CMAKE_BUILD_TYPE MATCHES Debug)
    MESSAGE(STATUS "Adding release flags to compiler.")
    set(GCC_DEBUG_COMPILE_FLAGS, "-g")
    set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -Wall ${GCC_DEBUG_COMPILE_FLAGS}")
endif(CMAKE_BUILD_TYPE MATCHES Debug)
# ###########################################################################


# ###########################################################################
# iCub and YARP Includes
# ###########################################################################
# Find packages
find_package(YARP)
find_package(ICUB)
list(APPEND CMAKE_MODULE_PATH ${YARP_MODULE_PATH})
list(APPEND CMAKE_MODULE_PATH ${ICUB_MODULE_PATH})
include(YarpInstallationHelpers)
include(YarpInstallationHelpers) # pick up yarp's cmake scripts

find_package(ICUBcontrib)
list(APPEND CMAKE_MODULE_PATH ${ICUBCONTRIB_MODULE_PATH})
include(ICUBcontribHelpers)
include(ICUBcontribOptions)
icubcontrib_set_default_prefix()
#set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} ${ICUB_LINK_FLAGS}")


# Include directories
include_directories(${YARP_INCLUDE_DIRS})
include_directories(${ICUB_INCLUDE_DIRS} ${YARP_INCLUDE_DIRS})
# ###########################################################################


# ###########################################################################
# Project content
# ###########################################################################
# Subdirectories
add_subdirectory(app/)  # Applications and contexts
add_subdirectory(src/)  # Source code
# ###########################################################################

