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



#ifndef __IAITABLETOP_FTSENSORREAD_THREAD_H__
#define __IAITABLETOP_FTSENSORREAD_THREAD_H__

#include <string>
#include <vector>
#include <deque>

#include <yarp/os/RateThread.h>
#include <yarp/os/BufferedPort.h>
#include <yarp/sig/Vector.h>
#include <yarp/dev/SerialInterfaces.h>
#include <yarp/os/Semaphore.h>

namespace IAITableTop {
    class IAITableTopFTSensorReadThread : public yarp::os::RateThread {
        private:
            /* ****** Module attributes                             ****** */
            /** The thread period. */
            int period;

            /* ******* Ports.                                       ******* */
            yarp::os::BufferedPort<yarp::sig::Vector> portFTSensorReaderInData;
            
            /* ******* Serial port attributes.                      ******* */
            /** The serial port I/O mutex. */
            yarp::os::Semaphore *serialMutex;
            /** The Serial port interface. */
            yarp::dev::ISerialDevice *iSerialPort;

            /* ******* FT Sensor specs                              ******* */
            /** FT sensor safety thresholds. */
            std::vector<double> safetyThresholds;

            /* ****** Debug attributes                              ****** */
            std::string dbgTag;

        public:
            IAITableTopFTSensorReadThread(const int aPeriod, yarp::dev::ISerialDevice * const aISerialPort, yarp::os::Semaphore * const aSerialMutex, const std::vector<double> &aSafetyThresholds);
            virtual ~IAITableTopFTSensorReadThread();

            virtual bool threadInit(void);
            virtual void run(void);
            virtual void threadRelease(void);

            /**
             * Get the port on which FT sensor data is input for reading.
             *
             * \return A reference to the port
             */
            yarp::os::BufferedPort<yarp::sig::Vector> &getInFTSensorPort(void);

        private:
            /**
             * Check if the FT sensor values are higher than the thresholds.
             * Flag the values which are found to be higher than the thresholds.
             *
             * \param i_vals The FT sensor values to check
             * \param o_reachedLimit List of boolean flags for each FT value. 
             *      These are set to true if the given value was found to be higher than the threshold
             *
             * \return True if any value is higher than the threshold
             */
            bool checkFTValues(yarp::sig::Vector * const i_vals, std::deque<bool> &o_reachedLimit);
    };
}

#endif

