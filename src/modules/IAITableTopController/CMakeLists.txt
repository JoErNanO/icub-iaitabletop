# Copyright: 2014 Francesco Giovannini, iCub Facility - Istituto Italiano di Tecnologia
# Author: Francesco Giovannini
# CopyPolicy: Released under the terms of the GNU GPL v2.0.
# 

# ###########################################################################
# The IAITableTopController module.
# ###########################################################################
set(MODULENAME IAITableTopController)
# ###########################################################################


# ###########################################################################
# The included source code
# ###########################################################################
set(INC_HEADERS
        include/IAITableTopControllerModule.h
        include/IAITableTopPositionReadThread.h
        include/IAITableTopFTSensorReadThread.h
        include/ParamMatrixXYZ.h
    )

set(INC_SOURCES
        IAITableTopControllerModule.cpp
        IAITableTopPositionReadThread.cpp
        IAITableTopFTSensorReadThread.cpp
        ParamMatrixXYZ.cpp
        main.cpp
    )
# ###########################################################################


# ###########################################################################
# The include directory 
# ###########################################################################
include_directories(include/)
include_directories(${YARP_INCLUDE_DIRS})
# ###########################################################################


# ###########################################################################
# The executable
# ###########################################################################
# Generate list of target link libraries
list(APPEND TARG_LINK_LIBS icubmod)
    
add_executable(${MODULENAME} ${INC_HEADERS} ${INC_SOURCES})
target_link_libraries(${MODULENAME} ${YARP_LIBRARIES} ${TARG_LINK_LIBS})
install(TARGETS ${MODULENAME} DESTINATION bin)
# ###########################################################################
