##
## Copyright © 2017-2019,
## Battelle Memorial Institute; Lawrence Livermore National Security, LLC; Alliance for Sustainable Energy, LLC.  See the top-level NOTICE for
## additional details. All rights reserved.
## SPDX-License-Identifier: BSD-3-Clause
##

## * @file
## @brief data structures for the C-API
##

import helics_enums

## * opaque object representing an input

type
  helics_input* = pointer

## * opaque object representing a publication

type
  helics_publication* = pointer

## * opaque object representing an endpoint

type
  helics_endpoint* = pointer

## * opaque object representing a filter

type
  helics_filter* = pointer

## * opaque object representing a core

type
  helics_core* = pointer

## * opaque object representing a broker

type
  helics_broker* = pointer

## * opaque object representing a federate

type
  helics_federate* = pointer

## * opaque object representing a filter info object structure

type
  helics_federate_info* = pointer

## * opaque object representing a query

type
  helics_query* = pointer

## * time definition used in the C interface to helics

type
  helics_time* = cdouble

var helics_time_zero*: helics_time = 0.0

## !< definition of time zero-the beginning of simulation

var helics_time_epsilon*: helics_time = 1e-09

## !< definition of the minimum time resolution

var helics_time_invalid*: helics_time = -1.785e+39

## !< definition of an invalid time that has no meaning

var helics_time_maxtime*: helics_time = 1e+53

## !< definition of time signifying the federate has terminated or to run until the end of the simulation
## * defining a boolean type for use in the helics interface

type
  helics_bool* = cint

var helics_true*: helics_bool = 1

## !< indicator used for a true response

var helics_false*: helics_bool = 0

## !< indicator used for a false response
## * enumeration of the different iteration results

type
  helics_iteration_request* = enum
    helics_iteration_request_no_iteration, ## !< no iteration is requested
    helics_iteration_request_force_iteration, ## !< force iteration return when able
    helics_iteration_request_iterate_if_needed ## !< only return an iteration if necessary


## * enumeration of possible return values from an iterative time request

type
  helics_iteration_result* = enum
    helics_iteration_result_next_step, ## !< the iterations have progressed to the next time
    helics_iteration_result_error, ## !< there was an error
    helics_iteration_result_halted, ## !< the federation has halted
    helics_iteration_result_iterating ## !< the federate is iterating at current time


## * enumeration of possible federate states

type
  helics_federate_state* = enum
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
  helics_complex* {.bycopy.} = object
    real*: cdouble
    imag*: cdouble


## *
##   Message_t mapped to a c compatible structure
##

type
  helics_message* {.bycopy.} = object
    time*: helics_time         ## !< message time
    data*: cstring             ## !< message data
    length*: int64_t           ## !< message length
    messageID*: int32_t        ## !< message identification information
    flags*: int16_t            ## !< flags related to the message
    original_source*: cstring  ## * original source
    source*: cstring           ## !< the most recent source
    dest*: cstring             ## !< the final destination
    original_dest*: cstring    ## !< the original destination of the message


## *
##  helics error object
##
##  if error_code==0 there is no error, if error_code!=0 there is an error and message will contain a string
##     otherwise it will be an empty string
##

type
  helics_error* {.bycopy.} = object
    error_code*: int32_t       ## !< an error code associated with the error
    message*: cstring          ## !< a message associated with the error

