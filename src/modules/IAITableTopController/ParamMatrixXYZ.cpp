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


#include <ParamMatrixXYZ.h>

using IAITableTop::ParamMatrixXYZ;
using std::vector;


/* *********************************************************************************************************************** */
/* ******* Constructor                                                      ********************************************** */   
ParamMatrixXYZ::ParamMatrixXYZ() {}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
/* ******* Destructor                                                       ********************************************** */   
ParamMatrixXYZ::~ParamMatrixXYZ() {}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
void ParamMatrixXYZ::resize(int &i_size) {
    int value = 0;
    resize(i_size, value);
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
void ParamMatrixXYZ::resize(int &i_size, int &i_value) {
    X.resize(i_size, i_value);
    Y.resize(i_size, i_value);
    Z.resize(i_size, i_value);
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
vector<int> &ParamMatrixXYZ::getX(void) {
    return X;
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
vector<int> &ParamMatrixXYZ::getY(void) {
    return Y;
}
/* *********************************************************************************************************************** */


/* *********************************************************************************************************************** */
vector<int> &ParamMatrixXYZ::getZ(void) {
    return Z;
}
/* *********************************************************************************************************************** */

