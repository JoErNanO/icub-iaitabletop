iCub IAITableTop
================

This repository contains an iCub Module to control the IAI TableTop robot. 
The module takes a list of (X, Y, Z) positions to be reached in sequential order loops through them until the final position is reached.


##IAITableTopController
Building this project creates one YARP module: _IAITableTopController_.
This is a multiplatform module relying upon yarpdev's to communicate with the robot via serial port.
In particular, this module needs the following to be enabled when compiling YARP:
```
    ENABLE_yarpdev_serial           ON
    ENABLE_yarpdev_serialport       ON
```


##Documentation
The documentation for the project modules can be found [here](http://robotology.github.io/icub-iaitabletop/doc/html/modules.html).

Altenatively you can generate the documentation locally by running:
```bash
    doxygen conf/Doxyfile
```
from the root of the cloned repository.
The documentation will be generated in the _doc/_ directory.



Project Info
============

####Build Status
[![Build Status](https://travis-ci.org/robotology/icub-iaitabletop.svg?branch=master)](https://travis-ci.org/robotology/icub-iaitabletop)
