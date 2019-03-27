/*
Copyright © 2017-2019,
Battelle Memorial Institute; Lawrence Livermore National Security, LLC; Alliance for Sustainable Energy, LLC
All rights reserved. 

SPDX-License-Identifier: BSD-3-Clause

*/
#pragma once

#include "compiler-config.h"

#define HELICS_HAVE_MPI 0

#define HELICS_HAVE_ZEROMQ 1

/* #undef DISABLE_TCP_CORE */
/* #undef DISABLE_IPC_CORE */
/* #undef DISABLE_UDP_CORE */
/* #undef DISABLE_TEST_CORE */


#define ENABLE_LOGGING
#define ENABLE_TRACE_LOGGING
#define ENABLE_DEBUG_LOGGING

/* #undef BOOST_STATIC */

/* #undef HELICS_USE_PICOSECOND_TIME */

#define BOOST_VERSION_LEVEL 68

#define HELICS_VERSION_MAJOR 2
#define HELICS_VERSION_MINOR 0
#define HELICS_VERSION_PATCH 0
#define HELICS_VERSION 2.0.0
#define HELICS_VERSION_BUILD ""
#define HELICS_VERSION_STRING "2.0.0 (03-08-19)"
#define HELICS_DATE "03-08-19"

