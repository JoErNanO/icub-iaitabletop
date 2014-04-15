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



#include "IAITableTopFTSensorReadThread.h"

#include <iostream>
#include <cmath>

#include <yarp/os/Time.h>

using IAITableTop::IAITableTopFTSensorReadThread;

using std::cerr;
using std::cout;

using yarp::os::RateThread;
using yarp::os::Time;

#define IAITABLETOP_TH_FTREAD_DEBUG 0


/* *********************************************************************************************************************** */
/* ******* Constructor                                                      ********************************************** */   
IAITableTopFTSensorReadThread::IAITableTopFTSensorReadThread(const int aPeriod, yarp::dev::ISerialDevice * const aISerialPort, yarp::os::Semaphore * const aSerialMutex, const std::vector<double> &aSafetyThresholds)
    : RateThread(aPeriod) {
    period = aPeriod;
    serialMutex = aSerialMutex;
    iSerialPort = aISerialPort;
    safetyThresholds = aSafetyThresholds;

    dbgTag = "IAITableTopFTSensorReadThread: ";
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Destructor                                                       ********************************************** */   
IAITableTopFTSensorReadThread::~IAITableTopFTSensorReadThread() {}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Initialise thread                                                ********************************************** */
bool IAITableTopFTSensorReadThread::threadInit(void) {
    cout << dbgTag << "Initialising. \n";

    // Open ports
    portFTSensorReaderInData.open("/IAITableTop/FTReader/data:i");
    
    cout << dbgTag << "Initialised correctly. \n";
    
    return true;
}
/* *********************************************************************************************************************** */



/* *********************************************************************************************************************** */
/* ******* Run thread                                                       ********************************************** */
void IAITableTopFTSensorReadThread::run(void) {
    using std::deque;
    using yarp::sig::Vector;
    using yarp::os::Bottle;

    // Read sensor data from port
    Vector *data = portFTSensorReaderInData.read(false);
    if ((data) && (data->size() > 0)) {
#if IAITABLETOP_TH_FTREAD_DEBUG
        // Print out FT sensor data
        cout << dbgTag << "FT sensor data: ";
        for (size_t i = 0; i < data->size(); ++i) {
            cout << (*data)[i] << " ";
        }
        cout << "\n";
#endif

        // Check sensor data size against safety threshold size
        if (data->size() != safetyThresholds.size()) {
            cerr << dbgTag << "The FT sensor data and the safety threshold vector do not have the same size. The FT sensor data size is " << data->size()
                << " , while the safety threshold vector size is " << safetyThresholds.size() << ". Check the module configuration file. \n";
            cerr << dbgTag << "An error occurred so the thread will now stop. \n";
            askToStop();
        } else {
            // Check if values are higher than their respective thresholds
            deque<bool> flags;
            if (checkFTValues(data, flags)) {
                cout << dbgTag << "FT sensor safety threshold reached. \n";
                serialMutex->wait();
                
                // Send stop command to all axes
                Bottle cmd, reply;
                cmd.addString("!992380701@@\n");
                iSerialPort->send(cmd);

#ifdef _WIN32
                // Wait for a small delay to avoid reading incomplete replies
                Time::delay(0.05);
#endif
                iSerialPort->receive(reply);

                serialMutex->post();

                cerr << dbgTag << "The FT sensor recorded a value which is higher than its safety threshold. The robot will now be stopped. \n";
                askToStop();
            }
        }
    }
}  
/* *********************************************************************************************************************** */



/* *********************************************************************************************************************** */
/* ******* Release thread                                                   ********************************************** */
void IAITableTopFTSensorReadThread::threadRelease(void) {
    cout << dbgTag << "Releasing. \n";
    
    // Interrupt ports
    portFTSensorReaderInData.interrupt();

    // Close ports
    portFTSensorReaderInData.close();

    cout << dbgTag << "Released. \n";
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Check if FT sensor values are higher than the threshold.         ********************************************** */
bool IAITableTopFTSensorReadThread::checkFTValues(yarp::sig::Vector * const i_vals, std::deque<bool> &o_reachedLimit) {
    bool thresholdReached = false;
    
    o_reachedLimit.resize(i_vals->size());
    // Check all FT values
    for (size_t i = 0; i < i_vals->size(); ++i) {
        o_reachedLimit[i] = (std::abs((*i_vals)[i]) >= safetyThresholds[i]);

        if (!thresholdReached) {
            thresholdReached = o_reachedLimit[i];
        }
    }

    return thresholdReached;
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Get the FT sensor input port.                                   ********************************************** */
yarp::os::BufferedPort<yarp::sig::Vector> &IAITableTopFTSensorReadThread::getInFTSensorPort(void) {
    return this->portFTSensorReaderInData;
}
/* *********************************************************************************************************************** */
