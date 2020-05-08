##
## Copyright (c) 2017-2020,
## Battelle Memorial Institute; Lawrence Livermore National Security, LLC; Alliance for Sustainable Energy, LLC.  See the top-level NOTICE for
## additional details. All rights reserved.
## SPDX-License-Identifier: BSD-3-Clause
##

## *
##  @file
##  @brief Data structures for the C api
##

when defined(windows):
  const helicsSharedLib* = "helicsSharedLib.dll"
elif defined(macosx):
  const helicsSharedLib* = "libhelicsSharedLib.dylib"
else:
  const helicsSharedLib* = "libhelicsSharedLib.so"

include helics_enums

## *
##  opaque object representing an input
##

type
  helics_input* = pointer

## *
##  opaque object representing a publication
##

type
  helics_publication* = pointer

## *
##  opaque object representing an endpoint
##

type
  helics_endpoint* = pointer

## *
##  opaque object representing a filter
##

type
  helics_filter* = pointer

## *
##  opaque object representing a core
##

type
  helics_core* = pointer

## *
##  opaque object representing a broker
##

type
  helics_broker* = pointer

## *
##  opaque object representing a federate
##

type
  helics_federate* = pointer

## *
##  opaque object representing a filter info object structure
##

type
  helics_federate_info* = pointer

## *
##  opaque object representing a query
##

type
  helics_query* = pointer

## *
##  opaque object representing a message
##

type
  helics_message_object* = pointer

## *
##  time definition used in the C interface to helics
##

type
  helics_time* = cdouble

const helics_time_zero*: helics_time = 0.0
const helics_time_epsilon*: helics_time = 1.0e-9
const helics_time_invalid*: helics_time = -1.785e39
const helics_time_maxtime*: helics_time = 9223372036.854774

## !< definition of time signifying the federate has
##                                                              terminated or to run until the end of the simulation
## *
##  defining a boolean type for use in the helics interface
##

type
  helics_bool* = cint

var helics_true*: helics_bool = 1

## !< indicator used for a true response

var helics_false*: helics_bool = 2

## !< indicator used for a false response
## *
##  enumeration of the different iteration results
##

type
  helics_iteration_request* {.size: sizeof(cint).} = enum
    helics_iteration_request_no_iteration, ## !< no iteration is requested
    helics_iteration_request_force_iteration, ## !< force iteration return when able
    helics_iteration_request_iterate_if_needed ## !< only return an iteration if necessary


## *
##  enumeration of possible return values from an iterative time request
##

type
  helics_iteration_result* {.size: sizeof(cint).} = enum
    helics_iteration_result_next_step, ## !< the iterations have progressed to the next time
    helics_iteration_result_error, ## !< there was an error
    helics_iteration_result_halted, ## !< the federation has halted
    helics_iteration_result_iterating ## !< the federate is iterating at current time


## *
##  enumeration of possible federate states
##

type
  helics_federate_state* {.size: sizeof(cint).} = enum
    helics_state_startup = 0,   ## !< when created the federate is in startup state
    helics_state_initialization, ## !< entered after the enterInitializingMode call has returned
    helics_state_execution,   ## !< entered after the enterExectuationState call has returned
    helics_state_finalize,    ## !< the federate has finished executing normally final values may be retrieved
    helics_state_error, ## !< error state no core communication is possible but values can be retrieved
                       ##  the following states are for asynchronous operations
    helics_state_pending_init, ## !< indicator that the federate is pending entry to initialization state
    helics_state_pending_exec, ## !< state pending EnterExecution State
    helics_state_pending_time, ## !< state that the federate is pending a timeRequest
    helics_state_pending_iterative_time, ## !< state that the federate is pending an iterative time request
    helics_state_pending_finalize ## !< state that the federate is pending a finalize request


## *
##   structure defining a basic complex type
##

type
  helics_complex* = object
    real* : cdouble
    imag* : cdouble


## *
##   Message_t mapped to a c compatible structure
##
##  @details use of this structure is deprecated in HELICS 2.5 and removed in HELICS 3.0
##

type
  helics_message* = object
    time*: helics_time ## !< message time
    data*: cstring ## !< message data
    length*: int64 ## !< message length
    messageID*: int32 ## !< message identification information
    flags*: int16 ## !< flags related to the message
    original_source*: cstring ## !< original source
    source*: cstring ## !< the most recent source
    dest*: cstring ## !< the final destination
    original_dest*: cstring ## !< the original destination of the message


## *
##  helics error object
##
##  if error_code==0 there is no error, if error_code!=0 there is an error and message will contain a string,
##  otherwise it will be an empty string
##

type
  helics_error* = object
    error_code*: int32 ## !< an error code associated with the error
    message*: cstring ## !< a message associated with the error