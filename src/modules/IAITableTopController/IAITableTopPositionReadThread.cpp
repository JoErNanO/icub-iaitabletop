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



#include "IAITableTopPositionReadThread.h"

#include <iostream>
#include <stdlib.h>

#include <yarp/os/Time.h>

using IAITableTop::IAITableTopPositionReadThread;

using std::cerr;
using std::cout;
using std::string;

using yarp::os::RateThread;
using yarp::os::Bottle;
using yarp::sig::Vector;
using yarp::os::Time;

#define IAITABLETOP_TH_POSREAD_DEBUG 0

/* *********************************************************************************************************************** */
/* ******* Constructor                                                      ********************************************** */   
IAITableTopPositionReadThread::IAITableTopPositionReadThread(const int aPeriod, yarp::dev::ISerialDevice * const aISerialPort, yarp::os::Semaphore * const aSerialMutex)
        : RateThread(aPeriod) {
    period = aPeriod;
    serialMutex = aSerialMutex;
    iSerialPort = aISerialPort;

    dbgTag = "IAITableTopPositionReadThread: ";
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Destructor                                                       ********************************************** */   
IAITableTopPositionReadThread::~IAITableTopPositionReadThread() {}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Initialise thread                                                ********************************************** */
bool IAITableTopPositionReadThread::threadInit(void) {
    cout << dbgTag << "Initialising. \n";

    // Open ports
    portIAITTPositionReadOutPos.open("/IAITableTop/posreader/position:o");
    portIAITTPositionReadOutStatus.open("/IAITableTop/posreader/status:o");
    
    cout << dbgTag << "Initialised correctly. \n";
    
    return true;
}
/* *********************************************************************************************************************** */



/* *********************************************************************************************************************** */
/* ******* Run thread                                                       ********************************************** */
void IAITableTopPositionReadThread::run(void) {
    Vector &pos = portIAITTPositionReadOutPos.prepare();
    Vector &status = portIAITTPositionReadOutStatus.prepare();

    pos.clear();
    status.clear();

    // Read data from serial
    if(readPosition(pos, status)) {
        // Store timestamp
        portStamp.update();
        // Attach it to the port
        portIAITTPositionReadOutPos.setEnvelope(portStamp);
        portIAITTPositionReadOutStatus.setEnvelope(portStamp);

        // Write position and axis status data
        portIAITTPositionReadOutPos.write();
        portIAITTPositionReadOutStatus.write();
    } else {
        cout << dbgTag << "Could not read robot position. \n";
        askToStop();
    }
}  
/* *********************************************************************************************************************** */



/* *********************************************************************************************************************** */
/* ******* Release thread                                                   ********************************************** */
void IAITableTopPositionReadThread::threadRelease(void) {
    cout << dbgTag << "Releasing. \n";
    
    // Close ports
    portIAITTPositionReadOutPos.interrupt();
    portIAITTPositionReadOutStatus.interrupt();

    portIAITTPositionReadOutPos.close();
    portIAITTPositionReadOutStatus.close();

    cout << dbgTag << "Released. \n";
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Release thread                                                   ********************************************** */
bool IAITableTopPositionReadThread::readPosition(yarp::sig::Vector &o_pos, yarp::sig::Vector &o_status) {
    bool ok = false;
    serialMutex->wait();

    // Read position
    Bottle cmd, reply;
    cmd.addString("!99212078@@\n");     // Query the robot position
    iSerialPort->send(cmd);

#ifdef _WIN32
    // Wait for a small delay to avoid reading incomplete replies
    Time::delay(0.05);
#endif
    iSerialPort->receive(reply);

    serialMutex->post();

    if (reply.size() > 0) {
        string sReply = reply.get(0).asString().c_str();
        if (sReply[0] == '#') {
            if (sReply.size() == 60) {
                // Break up reply string into position values
                long tmpStat = strtol(sReply.substr(8, 2).data(), NULL, 16);
                long tmpPos = strtol(sReply.substr(10, 14).data(), NULL, 16);  
                o_pos.push_back(tmpPos);
                o_status.push_back(tmpStat);

                tmpStat = strtol(sReply.substr(24, 2).data(), NULL, 16);
                tmpPos = strtol(sReply.substr(26, 14).data(), NULL, 16);      
                o_pos.push_back(tmpPos);
                o_status.push_back(tmpStat);

                tmpStat = strtol(sReply.substr(40, 2).data(), NULL, 16);
                tmpPos = strtol(sReply.substr(42, 14).data(), NULL, 16);
                o_pos.push_back(tmpPos);
                o_status.push_back(tmpStat);

#if IAITABLETOP_TH_POSREAD_DEBUG
                cout << dbgTag << sReply;
                cout << dbgTag << "Status/Position: ";
                for (size_t i = 0; i < o_pos.size(); ++i) {
                    cout << std::hex << std::showbase << o_status[i] << std::noshowbase << "/" << std::dec << o_pos[i] <<"\t";
                }
                cout << "\n";
#endif
                ok = true;
            } else {
                cout << dbgTag << "The reply is malformed. "
                    << "You might be reading data from the serial port at a rate which is too fast. "
                    << "Consider reducing the thread period. \n";
                ok = false;
            }
        } else {
            cout << dbgTag << "The robot replied with error code: " << sReply;
            ok = false;
        }
    } else {
        cout << dbgTag << "Cannot query robot position. \n";
        ok = false;
    }

    return ok;
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Get the axis status port.                                        ********************************************** */
yarp::os::BufferedPort<yarp::sig::Vector> &IAITableTopPositionReadThread::getOutStatusPort(void) {
    return this->portIAITTPositionReadOutStatus;
}
/* *********************************************************************************************************************** */
