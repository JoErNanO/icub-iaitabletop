/*
 * Copyright (C) 2014 Francesco Giovannini, iCub Facility - Istituto Italiano di Tecnologia
 * Authors: Francesco Giovannini
 * email:   francesco.giovannini@iit.it
 * website: www.robotcub.org
 * Permission is granted to copy, distribute, and/or modify this program
 * under the terms of the GNU General Public License, version 2 or any
 * later version published by the Free Software Foundation.
 *
 * A copy of the license can be found at
 * http://www.robotcub.org/icub/license/gpl.txt
 *
 * This program is distributed in the hope that it will be useful, but
 * WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the GNU General
 * Public License for more details
 */



/**
 * @ingroup icub_module
 * \defgroup IAITableTopController IAITableTopController
 * The IAITableTopController is a module which controls the position of the IAI TableTop robot.
 * This module also cyclically polls the robot position and axis status and this information is output on two yarp ports.
 *
 *
 * \section intro_sec Description
 * The IAI TableTop robot (http://www.intelligentactuator.com/tt-table-top-robot/) is a 3-axis robot which is controlled by sending position commands via a USB serial port.
 * The IAITableTopController takes a configuration file containing a detailed description of the experiment to be run.
 * The experiment is represented as a set of position steps to be maintained for a given time <b>t</b>.
 *
 * The positions are represented using absolute (X, Y, Z) coordinates with reference to the robot frame.
 * From these coordinates the module builds the commands to be sent to the robot.
 * The robot uses a control loop to check if the movement is completed before any new movement command can be sent.
 *
 *
 * \section lib_sec Libraries and Dependencies
 * This module depends on various YARP libraries.
 *
 * This module also relies on the serial and serialport yarpdev modules to be enabled when compiling yarp.
 * This is done by setting:
 *
 *      ENABLE_yarpmod_serial           ON
 *      ENABLE_yarpmod_serialport       ON
 *
 * when building YARP from sources.
 *
 *
 * \section parameters_sec Parameters
 * <b>Command-line Parameters</b>
 * - -- from : Module ini configuration file.
 *
 *
 * <b>Configuration File Parameters</b>
 * - name : The module name.
 * - period : The module period in seconds.
 * - serialPortConfFile : The serial port configuration filename.
 * - experimentConfFile : The experiment configuration filename.
 *
 *
 * \section outputports_sec Output Ports
 * - /IAITableTopController/posreader/position:o [yarp::sig::Vector]  [default carrier:tcp]: This port outputs the (X, Y, Z) coordinates of the robot position.
 * - /IAITableTopController/posreader/status:o [yarp::sig::Vector]  [default carrier:tcp]: This port outputs the (X, Y ,Z) axis status flags.
 * - /IAITableTopController/controller/experiment/status:o [yarp::sig::Vector] [default carrier:tcp]: This port outputs the status (step n., time start, time end) of each experiment step. This data is useful when performing data analysis on the recorded signals later on.
 *
 *
 * \section conf_file_sec Configuration Files
 * - serialPortConfFile : The serial port configuration file.
 * - experimentConfFile : The experiment configuration file.
 *
 * <b>Serial Port Configuration File</b><br />
 * The skeleton of this file was taken from the YARP serialport module here: https://github.com/robotology/yarp/blob/master/src/modules/serial/serial.ini
 * The parameters depend on the serial device connected to the host machine and must be configured accordingly.
 * Below is an extract from the configuration file specific to the IAI Tabletop robot:
 *
 *     verbose 0
 *     # The port name
 *     comport /dev/ttyUSB0
 *     #comport COM3
 *     # The baud rate
 *     baudrate 115200
 *     # The parity mode (EVEN, ODD, NONE)
 *     paritymode NONE
 *     # The number of data bits
 *     databits 8
 *     # The number of stop bits
 *     stopbits 1
 *     ...
 *
 * <b>Serial Port Name - comport</b><br />
 * In particular, the <i>comport</i> parameter must be changed to reflect the name of the serial port mounted on the host machine.
 * A typical Linux serial port configuration will look like this:
 *
 *     # The port name - Linux
 *     comport /dev/ttyUSB0
 *
 * Whereas a typical Windows serial port configuration will look like this:
 *
 *     # The port name - Windows
 *     comport COM3
 *
 * <b>Experiment Configuration File</b><br />
 * The module expects a configuration file for the experiment to be run using the robot.
 * This file is structured as follows:
 *
 *     [experiment]
 *     # Number of columns in the posVelAccDecTime array below:
 *     nCols 13
 *
 *     # Position values are in um (10^-3)mm
 *     # Velocities are in mm/s
 *     # Accelerations/Decelerations are in 10^-2G
 *     #   (X Y Z velX velY velZ accX accY accZ decX decY decZ t) = 13
 *     posVelAccDecTime (
 *          coordinate_X ...Y ...Z velocity_X ...Y ...Z acceleration_X ...Y ...Z deceleration_X ...Y ...Z step_time \
 *          coordinate_X ...Y ...Z velocity_X ...Y ...Z acceleration_X ...Y ...Z deceleration_X ...Y ...Z step_time \
 *          ...
 *     )
 *
 * \section tested_os_sec Tested OS
 * Linux, Windows
 *
 *
 * \section example_sec Example Instantiation of the Module
 * IAITableTopController --from confIAITableTopController.ini
 *
 *
 * \author Francesco Giovannini (francesco.giovannini@iit.it)
 *
 * Copyright (C) 2014 Francesco Giovannini, iCub Facility - Istituto Italiano di Tecnologia
 *
 * CopyPolicy: Released under the terms of the GNU GPL v2.0.
 *
 * This file can be edited at src/modules/IAITableTopController/include/IAITableTopControllerModule.h
 */

#ifndef __IAITABLETOPCONTROLLER_MODULE_H__
#define __IAITABLETOPCONTROLLER_MODULE_H__

#include <string>
#include <sstream>

#include <yarp/os/RFModule.h>
#include <yarp/os/BufferedPort.h>
#include <yarp/dev/PolyDriver.h>
#include <yarp/dev/SerialInterfaces.h>
#include <yarp/os/Semaphore.h>
#include <yarp/os/Stamp.h>
#include <yarp/sig/Vector.h>

#include "ParamMatrixXYZ.h"
#include "IAITableTopPositionReadThread.h"
#include "IAITableTopFTSensorReadThread.h"

namespace IAITableTop {
    class IAITableTopControllerModule : public yarp::os::RFModule {
        private:
            /* ****** Module attributes                             ****** */
            /** The module period. */
            double period;
            /** The module name. */
            std::string moduleName;
            /** The delay to wait before reading robot status from the specific port. */
            double statusReadDelay;

            /** The thread used to read the robot position and output it on a YARP port. */
            IAITableTopPositionReadThread *thPosRead;
            /** The thread used to monitor the applied force by reading the FT sensor. */
            IAITableTopFTSensorReadThread *thFTRead;

            /** The serial port I/O mutex. */
            yarp::os::Semaphore *serialMutex;

            /* ******* Serial port device                           ******* */
            /** The Serial port polydriver. */
            yarp::dev::PolyDriver clientSerial;
            /** The Serial port interface. */
            yarp::dev::ISerialDevice *iSerialPort;

            /* ******* Experiment attributes                        ******* */
            /** The experiment step counter. */
            int stepCounter;
            /** The number of experiments steps. */
            int nSteps;
            /** The (X, Y, Z) positions to be reached during the experiment. */
            ParamMatrixXYZ positions;
            /** The (X, Y, Z) velocities to be used for moving during the experiment. */
            ParamMatrixXYZ velocities;
            /** The (X, Y, Z) accelerations to be used for moving during the experiment. */
            ParamMatrixXYZ accelerations;
            /** The (X, Y, Z) decelerations to be used for moving during the experiment. */
            ParamMatrixXYZ decelerations;
            /** The time intervals during which each position is to be maintained. */
            std::vector<int> timeIntervals;

            /* ****** Ports                                         ****** */
            /** The port timestamp. */
            yarp::os::Stamp portStamp;
            /** Input port for the robot position coordinates. */
            yarp::os::BufferedPort<yarp::sig::Vector> portIAITTPositionReadInPos;
            /** Input port for the robot axis status. */
            yarp::os::BufferedPort<yarp::sig::Vector> portIAITTPositionReadInStatus;
            /** Output port for experiment step information. */
            yarp::os::BufferedPort<yarp::sig::Vector> portIAITTControllerOutExperimentStatus;


            /* ****** Debug attributes                              ****** */
            std::string dbgTag;

        public:
            /**
             * Default constructor.
             */
            IAITableTopControllerModule();

            /**
             * Default destructor.
             */
            virtual ~IAITableTopControllerModule();
            virtual double getPeriod();
            virtual bool configure(yarp::os::ResourceFinder &rf);
            virtual bool updateModule();
            virtual bool interruptModule();
            virtual bool close();
            virtual bool respond(const yarp::os::Bottle &command, yarp::os::Bottle &reply);

        private:
            /**
             * Wait for the movement on the given axis to be completed.
             *
             * \return True upon movement completion
             */
            bool waitMoveDone(const double &i_period, const double &i_timeout);

            /**
             * Build the movement command for the X axis.
             *
             * \param i_pos The position to reach
             * \param o_cmd The generated command string
             */
            void buildMoveAbsX(const int &i_pos, yarp::os::Bottle &o_cmd );

            /**
             * Build the movement command for the Y axis.
             *
             * \param i_pos The position to reach
             * \param o_cmd The generated command string
             */
            void buildMoveAbsY(const int &i_pos, yarp::os::Bottle &o_cmd );

            /**
             * Build the movement command for the Z axis.
             *
             * \param i_pos The position to reach
             * \param o_cmd The generated command string
             */
            void buildMoveAbsZ(const int &i_pos, yarp::os::Bottle &o_cmd );

            /**
             * Send the command to the serial port.
             * This is the only interface to be used with the serial port as it takes care of mutexing the connection and checking for errors.
             *
             * \param i_cmd The command to be sent
             *
             * \return True if the the command is sent and exectured correctly
             */
            bool sendCommandToSerial(const yarp::os::Bottle &i_cmd);

            /**
             * Send the command to the serial port.
             * Retrieve and store the reply.
             * This is the only interface to be used with the serial port as it takes care of mutexing the connection and checking for errors.
             *
             * \param i_cmd The command to be sent
             * \param o_data The reply
             *
             * \return True if the the command is sent and exectured correctly
             */
            bool sendCommandToSerial(const yarp::os::Bottle &i_cmd, std::string &o_data);

            /**
             * Read the data from the serial and check if the robot returned an error.
             *
             * \return False if the robot replied with an error
             */
            bool readDataFromSerial(void);

            /**
             * Read the data from the serial and check if the robot returned an error. This function also returns the read data.
             *
             * \param o_data The data read from the serial
             * \return False if the robot replied with an error
             */
            bool readDataFromSerial(std::string &o_data);

            /**
             * Check if the robot replied with an error.
             *
             * \param i_reply The robot reply to be checked
             * \return False if the robot replied with an error
             */
            bool checkError(const std::string &i_reply);

            /**
             * Convert the given number in its HEX string representation.
             *
             * \param i_num The number to be converted
             * \param o_ss The resulting HEX representation
              */
            void numToHex(const int &i_num, std::stringstream &o_ss);

            /**
             * Pad the given number with leading zeroes. Store the result in string representation.
             *
             * \param i_length The total length of the padded string
             * \param i_num The number to be padded
             * \param o_ss The resulting string representation
              */
            void padString(const int &i_length, const int &i_num, std::stringstream &o_ss);

            /**
             * Output the experiment status on the dedicated port.
             *
             * \param \i_timeStart The start time of the current experiment step
             * \param \i_timeEnd The end time of the current experiment step
             *
             * \return True upon success
             */
            bool writeExperimentStatus(const double &i_timeStart, const double &i_timeEnd);
    };
}

#endif

