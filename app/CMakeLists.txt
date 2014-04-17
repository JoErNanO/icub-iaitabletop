# Copyright: 2013 Francesco Giovannini, iCub Facility - Istituto Italiano di Tecnologia
# Author: Francesco Giovannini
# CopyPolicy: Released under the terms of the GNU GPL v2.0.
# 

# Search for application files
set(APP_SCRIPTS ${CMAKE_CURRENT_SOURCE_DIR}/applications/FingertipsTableTop.xml.template)

# Search for ini files
set(APP_CONF ${CMAKE_CURRENT_SOURCE_DIR}/contexts/${PROJECTNAME}/confIAITableTopController.ini)

# Search for module descriptor files
set(APP_MODULES ${CMAKE_CURRENT_SOURCE_DIR}/modules/${PROJECTNAME}.xml)

yarp_install(FILES ${APP_SCRIPTS} DESTINATION ${ICUBCONTRIB_APPLICATIONS_TEMPLATES_INSTALL_DIR})
yarp_install(FILES ${APP_CONF} DESTINATION ${ICUBCONTRIB_CONTEXTS_INSTALL_DIR}/${PROJECTNAME})
yarp_install(FILES ${APP_MODULES} DESTINATION ${ICUBCONTRIB_MODULES_INSTALL_DIR}/${PROJECTNAME})
