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


#ifndef __IAITABLETOPCONTROLLER_PARAMS_H__
#define __IAITABLETOPCONTROLLER_PARAMS_H__

#include <vector>

namespace IAITableTop {
    class ParamMatrixXYZ {
        private:
            std::vector<int> X;
            std::vector<int> Y;
            std::vector<int> Z;

        public:
            /**
             * Default constructor.
             */
            ParamMatrixXYZ();

            /**
             * Default destructor.
             */
            ~ParamMatrixXYZ();

            /**
             * Get the parameters for the X axis.
             *
             * \returns A reference to the X axis parameters.
             */
            std::vector<int> &getX(void);

            /**
             * Get the parameters for the Y axis.
             *
             * \returns A reference to the Y axis parameters.
             */
            std::vector<int> &getY(void);

            /**
             * Get the parameters for the Z axis.
             *
             * \returns A reference to the Z axis parameters.
             */
            std::vector<int> &getZ(void);
            
            /**
             * Resize X, Y, and Z data arrays.
             *
             * \param i_size The new size
             */
            void resize(int &i_size);

            /**
             * Resize X, Y, and Z data arrays and set all the elemenst to the given value.
             *
             * \param i_size The new size
             * \param i_value The default value to set foreach element in the vector
             */
            void resize(int &i_size, int &i_value);

    };
}

#endif
