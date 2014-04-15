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



#ifndef __IAITABLETOP_POSITIONREAD_THREAD__
#define __IAITABLETOP_POSITIONREAD_THREAD__

#include <string>

#include <yarp/os/RateThread.h>
#include <yarp/os/BufferedPort.h>
#include <yarp/sig/Vector.h>
#include <yarp/dev/SerialInterfaces.h>
#include <yarp/os/Semaphore.h>
#include <yarp/os/Stamp.h>

namespace IAITableTop {
    class IAITableTopPositionReadThread : public yarp::os::RateThread {
        private:
            /* ****** Module attributes                             ****** */
            int period;
            
            /* ****** Ports                                         ****** */
            /** Output port for the robot (X, Y, Z) position. */
            yarp::os::BufferedPort<yarp::sig::Vector> portIAITTPositionReadOutPos;
            /** Output port for the robot (X, Y, Z) status. */
            yarp::os::BufferedPort<yarp::sig::Vector> portIAITTPositionReadOutStatus;
            
            /** The port timestamp. */
            yarp::os::Stamp portStamp;
            /** The serial port I/O mutex. */
            yarp::os::Semaphore *serialMutex;
            /** The Serial port interface. */
            yarp::dev::ISerialDevice *iSerialPort;
            
            /* ****** Debug attributes                              ****** */
            std::string dbgTag;

        public:
            IAITableTopPositionReadThread(const int aPeriod, yarp::dev::ISerialDevice * const aISerialPort, yarp::os::Semaphore * const aSerialMutex);
            virtual ~IAITableTopPositionReadThread();

            virtual bool threadInit(void);
            virtual void run(void);
            virtual void threadRelease(void);

            /**
             * Get the output axis status port.
             *
             * \return A reference to the port
             */
            yarp::os::BufferedPort<yarp::sig::Vector> &getOutStatusPort(void);

        private:
            bool readPosition(yarp::sig::Vector &o_pos, yarp::sig::Vector &o_status);
    };
}

#endif

