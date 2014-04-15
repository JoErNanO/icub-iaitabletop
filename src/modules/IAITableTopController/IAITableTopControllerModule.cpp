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



#include "IAITableTopControllerModule.h"

#include <iostream>
#include <iomanip>
#include <string.h>
#include <vector>

#include <yarp/os/Property.h>
#include <yarp/os/Time.h>

using IAITableTop::IAITableTopControllerModule;

using std::cerr;
using std::cout;
using std::string;
using std::stringstream;

using yarp::os::ResourceFinder;
using yarp::os::Value;
using yarp::os::Bottle;
using yarp::os::Time;


#define IAITABLETOP_CONTROLLER_DEBUG 0


/* *********************************************************************************************************************** */
/* ******* Constructor                                                      ********************************************** */   
IAITableTopControllerModule::IAITableTopControllerModule() : RFModule() {
    period = 0.1;
#if IAITABLETOP_CONTROLLER_DEBUG
    statusReadDelay = 0.1;
#else
    statusReadDelay =  0.1;
#endif

    stepCounter = -1;
    nSteps = 0;

    dbgTag = "IAITableTopControllerModule: ";
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Destructor                                                       ********************************************** */   
IAITableTopControllerModule::~IAITableTopControllerModule() {}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Get Period                                                       ********************************************** */   
double IAITableTopControllerModule::getPeriod() { return period; }
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Configure module                                                 ********************************************** */   
bool IAITableTopControllerModule::configure(ResourceFinder &rf){
    using std::string;
    using std::vector;
    using yarp::os::Network;
    using yarp::os::Property;
    using yarp::os::Semaphore;

    cout << dbgTag << "Starting. \n";

    /* ****** Configure the Module                            ****** */
    // Get resource finder and extract properties
    moduleName = rf.check("name", Value("IAITableTopController"), "The module name.").asString().c_str();
    period = rf.check("period", 1.0).asDouble();

    // Serial port configuration parameters
    Bottle &confSerial = rf.findGroup("serial");
    string serialPortConfFile;
    if (confSerial.isNull()) {
        cerr << dbgTag << "Cannot find serial port parameters. Cannot start the module. \n";
        return false;
    } else {
        if (confSerial.check("serialPortConfFile")) {
            serialPortConfFile = rf.findFileByName(confSerial.find("serialPortConfFile").asString()).c_str();
        } else {
            cerr << dbgTag << "Serial port configuration file was not specified. Cannot start the module. \n";
            return false;
        }
    }


    // FT sensor specs
    bool hasFTSensor = false;
    string FTSensorPortName;
    vector<double> safetyThresholds;
    Bottle &confFTSensor = rf.findGroup("FTSensor");
    if (confFTSensor.isNull()) {
        cout << dbgTag << "The FT sensor specs parameter group [FTSensor] was not specified. Assuming no FT sensor is connected to the setup. \n";
        hasFTSensor = false;
    } else {
        hasFTSensor = true;

        // FT sensor port name
        if (!confFTSensor.check("FTSensorPortName")) {
            cout << dbgTag << "Could not find the FT sensor data port name \"FTSensorPortName\". Cannot start the module. \n";
            return false;
        } else {
            FTSensorPortName = confFTSensor.find("FTSensorPortName").asString().c_str();
        }

        // FT sensor thresholds
        if (!confFTSensor.check("safetyThresholds")) {
            cout << dbgTag << "Could not find the FT sensor safety thresholds. Cannot start the module. \n";
            return false;
        } else {
            Bottle *thresholdList = confFTSensor.find("safetyThresholds").asList();
            if (thresholdList->size() == 0) {
                cerr << dbgTag << "Expecting a threshold list containing more than one element. Cannot start the module. \n";
                return false;
            } else {
                safetyThresholds.resize(thresholdList->size());
                for (size_t i = 0; i < safetyThresholds.size(); ++i) {
                    safetyThresholds[i] = thresholdList->get(i).asDouble();
                }
            }
        }
    }


    // Find experiment descriptor file
    Bottle &confExperimentName = rf.findGroup("experiment");
    if (confExperimentName.isNull()) {
        cerr << dbgTag << "The experiment parameter group [experiment] was not specified. Cannot run the experiment. \n";
        return false;
    } else {
        if (!confExperimentName.check("experimentConfFile")) {
            cerr << dbgTag << "Could not find the file name of the experiment descriptor file. Cannot run the experiment. \n";
            return false;
        } else {
            // Find filename of experiment descriptor file
            yarp::os::ConstString confExperimentPath = rf.findFileByName(confExperimentName.find("experimentConfFile").asString());
            // Open it
            Property confExperimentParams;
            confExperimentParams.fromConfigFile(confExperimentPath);

            // Experiment configutation paramters
            Bottle &confExperiment = confExperimentParams.findGroup("experiment");
            if (confExperiment.isNull()) {
                cerr << dbgTag << "The experiment parameter group was not specified. Cannot run the experiment. \n";
                return false;
            } else {
                Value &confNCols = confExperiment.find("nCols");
                int nCols = 0;
                if (confNCols.isNull()) {
                    cerr << dbgTag << "The number of columns in the experiment parameter array was not specified. Cannot run the experiment. \n";
                    return false;
                } else {
                    nCols = confNCols.asInt();
                }

                Bottle *confParameters = confExperiment.find("posVelAccDecTime").asList();
                if (confParameters->isNull()) {  // Check for experiment parameters
                    cerr << dbgTag << "The experiment parameters were not specified. Cannot run the experiment. \n";
                    return false;
                } else {    // Unwrap experiment parameters

#if IAITABLETOP_CONTROLLER_DEBUG
                    cout << dbgTag << "DEBUG: Number of columns in array: " << nCols << ". \n";
                    cout << dbgTag << "DEBUG: Array content: \n";
                    for (int i = 0; i < confParameters->size(); ++i) {
                    if (i % nCols == 0) {
                            cout << "\t";
                    }
                        cout << confParameters->get(i).asDouble() << " ";
                        if ((i + 1) % nCols == 0) {
                            cout << "\n";
                        }
                    }
#endif

                    // Resize vectors
                    nSteps = confParameters->size() / nCols;
                    positions.resize(nSteps);
                    velocities.resize(nSteps);
                    accelerations.resize(nSteps);
                    decelerations.resize(nSteps);
                    timeIntervals.resize(nSteps);

                    int curStep = -1;   // Temp step counter to fill in data arrays
                    int j;
                    for (int i = 0; i < confParameters->size(); ++i) {
                        j = i % nCols;

                        switch (j) {
                            // X Y Z Positions
                            case 0:
                                curStep++;  // Increment counter every nCols steps
                                positions.getX()[curStep] = confParameters->get(i).asInt();
                                break;
                            case 1:
                                positions.getY()[curStep] = confParameters->get(i).asInt();
                                break;
                            case 2:
                                positions.getZ()[curStep] = confParameters->get(i).asInt();
                                break;
                            // X Y Z Velocities
                            case 3:
                                velocities.getX()[curStep] = confParameters->get(i).asInt();
                                break;
                            case 4:
                                velocities.getY()[curStep] = confParameters->get(i).asInt();
                                break;
                            case 5:
                                velocities.getZ()[curStep] = confParameters->get(i).asInt();
                                break;
                            // X Y Z Accelerations
                            case 6:
                                accelerations.getX()[curStep] = confParameters->get(i).asInt();
                                break;
                            case 7:
                                accelerations.getY()[curStep] = confParameters->get(i).asInt();
                                break;
                            case 8:
                                accelerations.getZ()[curStep] = confParameters->get(i).asInt();
                                break;
                            // X Y Z Decelerations
                            case 9:
                                decelerations.getX()[curStep] = confParameters->get(i).asInt();
                                break;
                            case 10:
                                decelerations.getY()[curStep] = confParameters->get(i).asInt();
                                break;
                            case 11:
                                decelerations.getZ()[curStep] = confParameters->get(i).asInt();
                                break;
                            // Time intervals
                            case 12:
                                timeIntervals[curStep] = confParameters->get(i).asInt();
                                break;
                        }
                    }
                }
            }
        }
    }

#if IAITABLETOP_CONTROLLER_DEBUG
    cout << dbgTag << "DEBUG: Generated parameter arrays contain: \n";
    for (size_t i = 0; i < positions.getX().size(); ++i) {
        cout << "\t" << positions.getX()[i] << " " << positions.getY()[i] << " " << positions.getZ()[i] 
            << " " << velocities.getX()[i] << " " << velocities.getY()[i] << " " << velocities.getZ()[i] 
            << " " << accelerations.getX()[i] << " " << accelerations.getY()[i] << " " << accelerations.getZ()[i] 
            << " " << decelerations.getX()[i] << " " << decelerations.getY()[i] << " " << decelerations.getZ()[i] 
            << " " << timeIntervals[i] << "\n"; 
    }
#endif


    /* ******* Open ports                                   ******* */
    portIAITTPositionReadInPos.open("/IAITableTop/controller/position:i");
    portIAITTPositionReadInStatus.open("/IAITableTop/controller/status:i");
    portIAITTControllerOutExperimentStatus.open("/IAITableTop/controller/experiment/status:o");
    

    /* ******* Create the semaphores                                ******* */
    serialMutex = new Semaphore();


    /* ******* Open serial port interface                   ******* */ 
    Property options;
    options.put("device", "serialport");
    options.fromConfigFile(serialPortConfFile, rf, false);
//    options.put("file", serialPortConfFile);

    if (!clientSerial.open(options)) {
        return false;
    }
    clientSerial.view(iSerialPort);
    if (!iSerialPort) {
        return false;
    }

    /* ******* Initialise robot                                     ******* */
    cout << dbgTag << "TableTop: Starting robot. \n";
    // Polling robot
    Bottle cmd;
    cmd.addString("!9925301@@\n");
    if(!sendCommandToSerial(cmd)) {
        return false;
    }
    // Enabling axes
    cmd.clear();
    cmd.addString("!99232071@@\n");
    cout << dbgTag << "TableTop: Turning ON x y z axes. \n";
    if(!sendCommandToSerial(cmd)) {
        return false;
    }

    cout << dbgTag << "TableTop: Initialisation done. \n";


    /* ******* Run threads                                          ******* */
    cout << dbgTag << "Starting threads. \n";

    // Position read thread
    // Thread period
    int thPeriod = 25;
#ifdef _WIN32
    thPeriod = 100;
#endif
    thPosRead = new IAITableTopPositionReadThread(thPeriod, iSerialPort, serialMutex);
    // Start the thread
    if(!thPosRead->start()) {
        cerr << dbgTag << "Could not start the PositionRead thread. \n";
        return false;
    }

    // FT Sensor read thread
    if (hasFTSensor) {
        thFTRead = new IAITableTopFTSensorReadThread(10, iSerialPort, serialMutex, safetyThresholds);
        if (!thFTRead->start()) {
            cerr << dbgTag << "Could not start the FTSensorRead thread. \n";
            return false;
        } else {
            // Connect the FT sensor port to the reader
            if(!Network::connect(FTSensorPortName, thFTRead->getInFTSensorPort().getName())) {
                cerr << dbgTag << "Cannot connect to the output FT sensor port \"" << FTSensorPortName << "\". Cannot start module.\n";
                return false;
            }
        }
    }


    cout << dbgTag << "Threads started. \n";

    /* ******* Connecting ports                                     ******* */
    cout << dbgTag << "Waiting for port connections. \n";
    Network::connect(thPosRead->getOutStatusPort().getName(), portIAITTPositionReadInStatus.getName());

    
    // Wait for the robot to reach the position described in the first experiment step
    if (!waitMoveDone(0.05, 10)) {
        cerr << dbgTag << "Could not complete the movement. \n";
        return false;
    }


    cout << dbgTag << "Started correctly. \n";

    return true;
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Update    module                                                 ********************************************** */   
bool IAITableTopControllerModule::updateModule() {
    using std::cout;
    using yarp::os::Network;

    // Check for running threads
    // Posreader thread
    if (!thPosRead->isRunning()) {
        cerr << dbgTag << "PositionRead thread is not running. Stopping the module. \n";
        return false;
    }
    // FTSensorReader thread
    if (!thFTRead->isRunning()) {
        cerr << dbgTag << "FTSensorRead thread is not running. Stopping the module. \n";
        return false;
    }


    // Run experiment
    if (stepCounter < 0) {
        // Wait for 5 seconds before starting the experiment
        Time::delay(5.0);

        // Connect datadumper
        Network::connect("/IAITableTop/posreader/position:o", "/dump_iaittpos");
        Network::connect(portIAITTControllerOutExperimentStatus.getName(), "/dump_iaittexp");
        Network::connect("/NIDAQmxReader/data/real:o", "/dump_nano17");
        Network::connect("/SkinTableTop/skin/fingertip", "/dump_fingertip");

        // Increment step counter: experiment is ready to be run
        stepCounter++;
    } else if ((stepCounter >= 0) && (stepCounter < nSteps)) {
        cout << "\n" << dbgTag << "Performing experiment step n. " << stepCounter << "\n";
        
        // Get step position
        Bottle cmdX, cmdY, cmdZ;
        buildMoveAbsX(stepCounter, cmdX);
        buildMoveAbsY(stepCounter, cmdY);
        buildMoveAbsZ(stepCounter, cmdZ);
       
        // Move to step position
        cout << dbgTag << "Moving to X position. \n";
        if(!sendCommandToSerial(cmdX)) {
            cerr << dbgTag << "Could not send movement command to robot. \n";
            return false;
        }
            
        cout << dbgTag << "Moving to Y position. \n";
        if(!sendCommandToSerial(cmdY)) {
            cerr << dbgTag << "Could not send movement command to robot. \n";
            return false;
        }
            
        cout << dbgTag << "Moving to Z position. \n";    
        if(!sendCommandToSerial(cmdZ)) {
            cerr << dbgTag << "Could not send movement command to robot. \n";
            return false;
        }

        // Wait before reading robot status. This ensures the retrieved status is up to date.
        Time::delay(statusReadDelay);

        // Wait for movement to be over
        if(!waitMoveDone(0.05, 10)) {
            cerr << dbgTag << "Could not complete the movement. \n";
            return false;
        }

        // Stay in reached position for the selected time
        double timeStart = Time::now();
        while(Time::now() - timeStart <= timeIntervals[stepCounter]) {
            Time::delay(0.01);
        }
        double timeEnd = Time::now();

        // Print out step time
        double deltaT = timeEnd - timeStart;
        cout  << dbgTag << "Elapsed time: " << deltaT << "s. \n";

        // Write out experiment status
        writeExperimentStatus(timeStart, timeEnd);

        // Increment step counter
        stepCounter++;
    } else {
        cout << dbgTag << "Experiment completed. \n";

        // Disconnect datadumper
        Network::disconnect("/IAITableTop/posreader/position:o", "/dump_iaittpos");
        Network::disconnect(portIAITTControllerOutExperimentStatus.getName(), "/dump_iaittexp");
        Network::disconnect("/NIDAQmxReader/data/real:o", "/dump_nano17");
        Network::disconnect("/SkinTableTop/skin/fingertip", "/dump_fingertip");

        return false;
    }

    return true; 
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Interrupt module                                                 ********************************************** */   
bool IAITableTopControllerModule::interruptModule() {
    cout << dbgTag << "Interrupting. \n";
    
    // Interrupt ports
    portIAITTPositionReadInPos.interrupt();
    portIAITTPositionReadInStatus.interrupt();

    cout << dbgTag << "Interrupted correctly. \n";

    return true;
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Close module                                                     ********************************************** */   
bool IAITableTopControllerModule::close() {
    cout << dbgTag << "Closing. \n";
    
    // Homing robot
    Bottle cmd;
    cmd.addString("!992330702002000@@\n");
    cout << dbgTag << "TableTop: Homing X, Y and Z axes. \n";
    if(!sendCommandToSerial(cmd)) {
        return false;
    }
    // Wait before reading robot status. This ensures the status is up to date.
    Time::delay(statusReadDelay);
    // Wait for movement to be over
    if(!waitMoveDone(0.05, 10)) {
        cerr << dbgTag << "Could not complete the movement. \n";
        return false;
    }

    // Close ports
    portIAITTPositionReadInPos.close();
    portIAITTPositionReadInStatus.close();
    
    // Stop threads
    thPosRead->stop();
    thFTRead->stop();

    // Delete threads
    if (thPosRead) {
        delete thPosRead;
    }
    if (thFTRead) {
        delete thFTRead;
    }

    // Delete semaphores
    if (serialMutex) {
        delete serialMutex;
    }

    // Close driver
    clientSerial.close();

    cout << dbgTag << "Closed. \n";
    
    return true;
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Respond to rpc calls                                             ********************************************** */   
bool IAITableTopControllerModule::respond(const Bottle &command, Bottle &reply) {

    return true;
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Waits for the movement to be complete.                           ********************************************** */
bool IAITableTopControllerModule::waitMoveDone(const double &i_period, const double &i_timeout) {
    using std::string;
    using yarp::sig::Vector;

    bool done = false;

    double tStart = Time::now();
    while (!done) {
        // Check for timeout
        if (Time::now() - tStart > i_timeout) {
            cerr << dbgTag << "Movement completion check timeout expired. \n";
            return false;
        }

        // Read axis status
        Vector *reply = portIAITTPositionReadInStatus.read(true);
        
        if ((reply) && (reply->size() > 0)) {
            // Check axis status - 0x1C == free
            done = (((*reply)[0] == 0x1C)
                && ((*reply)[1] == 0x1C)
                && ((*reply)[2] == 0x1C));

#if IAITABLETOP_CONTROLLER_DEBUG
            cout << dbgTag << "DEBUG: Axis status is: \t";
            for (size_t i = 0; i < reply->size(); ++i) {
                cout << std::hex << std::showbase << std::uppercase << (int) (*reply)[i] << " ";
            }
            cout << std::dec << std::noshowbase << std::nouppercase << "\n";
#endif

        } else {
//            cerr << dbgTag << "There was an error reading from the axis status port. \n";
            return false;
        }

        // Wait before reading checking again
        Time::delay(i_period);
    }

    std::cout << dbgTag << "TableTop: Movement complete." << "\n";

    return done;
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
void IAITableTopControllerModule::buildMoveAbsX(const int &i_pos, yarp::os::Bottle &o_cmd) {
    // Build string command
    stringstream cmdX;
    cmdX << "!9923401";
    padString(4, accelerations.getX()[i_pos], cmdX);
    padString(4, decelerations.getX()[i_pos], cmdX);
    padString(4, velocities.getX()[i_pos], cmdX);
    padString(8, positions.getX()[i_pos], cmdX);
    cmdX << "@@\n";
    
    // Add command to output bottle
    o_cmd.clear();
    o_cmd.addString(cmdX.str());
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
void IAITableTopControllerModule::buildMoveAbsY(const int &i_pos, yarp::os::Bottle &o_cmd) {
    // Build string command
    stringstream cmdY;
    cmdY << "!9923402";
    padString(4, accelerations.getY()[i_pos], cmdY);
    padString(4, decelerations.getY()[i_pos], cmdY);
    padString(4, velocities.getY()[i_pos], cmdY);
    padString(8, positions.getY()[i_pos], cmdY);
    cmdY << "@@\n";

    // Add command to output bottle
    o_cmd.clear();
    o_cmd.addString(cmdY.str());
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
void IAITableTopControllerModule::buildMoveAbsZ(const int &i_pos, yarp::os::Bottle &o_cmd) {
    // Build string command
    stringstream cmdZ;
    cmdZ << "!9923404";
    padString(4, accelerations.getZ()[i_pos], cmdZ);
    padString(4, decelerations.getZ()[i_pos], cmdZ);
    padString(4, velocities.getZ()[i_pos], cmdZ);
    padString(8, positions.getZ()[i_pos], cmdZ);
    cmdZ << "@@\n";

    // Add command to output bottle
    o_cmd.clear();
    o_cmd.addString(cmdZ.str());
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Send the command to the serial port.                             ********************************************** */
bool IAITableTopControllerModule::sendCommandToSerial(const yarp::os::Bottle &i_cmd) {
    string tmp;
    return sendCommandToSerial(i_cmd, tmp);
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Send the command to the serial port.                             ********************************************** */
bool IAITableTopControllerModule::sendCommandToSerial(const yarp::os::Bottle &i_cmd, std::string &o_data) {
    serialMutex->wait();

    iSerialPort->send(i_cmd);

#ifdef _WIN32
    // Wait for a small delay to avoid reading incomplete replies
    Time::delay(0.01);
#endif
    bool ok = readDataFromSerial(o_data);

    serialMutex->post();

    return ok;
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Read data from the serial port.                                  ********************************************** */
bool IAITableTopControllerModule::readDataFromSerial(void) {
    string tmp;
    return readDataFromSerial(tmp);
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Read data from the serial port and return it.                    ********************************************** */
bool IAITableTopControllerModule::readDataFromSerial(string &o_data) {
    Bottle reply;
    iSerialPort->receive(reply);
    if (reply.size() > 0) {
        o_data = reply.get(0).asString().c_str();
        if(checkError(o_data)) {
            cout << dbgTag << "TableTop: Robot replied: " << o_data; // << ". \n";
            return true;
        } else {
            cerr << dbgTag << "TableTop: Robot replied with error code " << o_data; // << ". \n";
            cerr << dbgTag << "TableTop: Could not complete the requested operation. \n";
            return false;
        }
    } else {
        return false;
    }
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Check if the robot returned error.                               ********************************************** */
bool IAITableTopControllerModule::checkError(const std::string &i_reply) {
    if (i_reply.size() > 0) {
        // Reply string starting with & identifies an error.
        if (i_reply[0] == '#') {
            return true;
        } else if (i_reply[0] == '&') {
            return false;
        } else {
            return false;
        }
    } else {
        return false;
    }
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Convert the input number into its hex string representation.     ********************************************** */
void IAITableTopControllerModule::numToHex(const int &i_num, std::stringstream &o_ss) {
    o_ss << std::hex << i_num;
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Pad the given string.                                            ********************************************** */
void IAITableTopControllerModule::padString(const int &i_length, const int &i_num, stringstream &o_ss) {
    using std::setw;
    using std::setfill;

    stringstream tmpSS;
    numToHex(i_num, tmpSS);
    o_ss << setfill('0') << setw(i_length) << std::hex << i_num;
#if 0
    cout << o_ss.str() << "\n";
#endif
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Write the experiment status to the port.                         ********************************************** */
bool IAITableTopControllerModule::writeExperimentStatus(const double &i_timeStart, const double &i_timeEnd) {
    using yarp::sig::Vector;

    Vector &out = portIAITTControllerOutExperimentStatus.prepare();
    portStamp.update();

    // Write step counter, tStart ant tEnd
    out.clear();
    out.push_back(stepCounter);
    out.push_back(i_timeStart);
    out.push_back(i_timeEnd);

    // Write data
    portIAITTControllerOutExperimentStatus.setEnvelope(portStamp);
    portIAITTControllerOutExperimentStatus.write();

    return true;
}
/* *********************************************************************************************************************** */
