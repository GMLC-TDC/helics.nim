#
# Copyright (c) 2017-2018,
# Battelle Memorial Institute; Lawrence Livermore National Security, LLC; Alliance for Sustainable
# Energy, LLC All rights reserved. See LICENSE file and DISCLAIMER for more details.

when defined(posix) and not defined(nintendoswitch):
  import dynlib except loadLib
  from posix import dlopen, RTLD_LAZY
else:
  import dynlib
import macros
import os

when defined(posix):
  # use own loadLib implementation that uses RTLD_LAZY instead of RTLD_NOW to
  # prevent SIGSEGVing the app
  proc loadLib(path: string): LibHandle =
    result = dlopen(path, RTLD_LAZY)

template enumOp*(op, typ, typout) =
  proc op*(x: typ, y: cint): typout {.borrow.}
  proc op*(x: cint, y: typ): typout {.borrow.}
  proc op*(x, y: typ): typout {.borrow.}

  proc op*(x: typ, y: int): typout = op(x, y.cint)
  proc op*(x: int, y: typ): typout = op(x.cint, y)

template defineEnum*(typ) =
  # Create a `distinct cint` type for C enums since Nim enums
  # need to be in order and cannot have duplicates.
  type
    typ* = distinct cint

  # Enum operations allowed
  enumOp(`+`,   typ, typ)
  enumOp(`-`,   typ, typ)
  enumOp(`*`,   typ, typ)
  enumOp(`<`,   typ, bool)
  enumOp(`<=`,  typ, bool)
  enumOp(`==`,  typ, bool)
  enumOp(`div`, typ, typ)
  enumOp(`mod`, typ, typ)

  # These don't work with `enumOp()` for some reason
  proc `shl`*(x: typ, y: cint): typ {.borrow.}
  proc `shl`*(x: cint, y: typ): typ {.borrow.}
  proc `shl`*(x, y: typ): typ {.borrow.}

  proc `shr`*(x: typ, y: cint): typ {.borrow.}
  proc `shr`*(x: cint, y: typ): typ {.borrow.}
  proc `shr`*(x, y: typ): typ {.borrow.}

  proc `or`*(x: typ, y: cint): typ {.borrow.}
  proc `or`*(x: cint, y: typ): typ {.borrow.}
  proc `or`*(x, y: typ): typ {.borrow.}

  proc `and`*(x: typ, y: cint): typ {.borrow.}
  proc `and`*(x: cint, y: typ): typ {.borrow.}
  proc `and`*(x, y: typ): typ {.borrow.}

  proc `xor`*(x: typ, y: cint): typ {.borrow.}
  proc `xor`*(x: cint, y: typ): typ {.borrow.}
  proc `xor`*(x, y: typ): typ {.borrow.}

  proc `/`*(x, y: typ): typ =
    return (x.float / y.float).cint.typ
  proc `/`*(x: typ, y: cint): typ = `/`(x, y.typ)
  proc `/`*(x: cint, y: typ): typ = `/`(x.typ, y)

  proc `$`*(x: typ): string {.borrow.}

# * pick a core type depending on compile configuration usually either ZMQ if available or TCP
defineEnum(HelicsCoreType)

# * enumeration of allowable data types for publications and inputs
defineEnum(HelicsDataType)

# * single character data type  this is intentionally the same as string
# * enumeration of possible federate flags
defineEnum(HelicsFederateFlags)

# * log level definitions
#
defineEnum(HelicsLogLevels)

# * enumeration of return values from the C interface functions
#
defineEnum(HelicsErrorTypes)

# * enumeration of properties that apply to federates
defineEnum(HelicsProperties)

# * enumeration of the multi_input operations
defineEnum(HelicsMultiInputMode)

# * enumeration of options that apply to handles
defineEnum(HelicsHandleOptions)

# * enumeration of the predefined filter types
defineEnum(HelicsFilterType)

# * enumeration of the different iteration results
#
defineEnum(HelicsIterationRequest)

# *
# * enumeration of possible return values from an iterative time request
#
defineEnum(HelicsIterationResult)

# *
# * enumeration of possible federate states
#
defineEnum(HelicsFederateState)

const
  HELICS_CORE_TYPE_DEFAULT* = (0).HelicsCoreType
  HELICS_CORE_TYPE_ZMQ* = (1).HelicsCoreType
  HELICS_CORE_TYPE_MPI* = (2).HelicsCoreType
  HELICS_CORE_TYPE_TEST* = (3).HelicsCoreType
  HELICS_CORE_TYPE_INTERPROCESS* = (4).HelicsCoreType
  HELICS_CORE_TYPE_IPC* = (5).HelicsCoreType
  HELICS_CORE_TYPE_TCP* = (6).HelicsCoreType
  HELICS_CORE_TYPE_UDP* = (7).HelicsCoreType
  HELICS_CORE_TYPE_ZMQ_TEST* = (10).HelicsCoreType
  HELICS_CORE_TYPE_NNG* = (9).HelicsCoreType
  HELICS_CORE_TYPE_TCP_SS* = (11).HelicsCoreType
  HELICS_CORE_TYPE_HTTP* = (12).HelicsCoreType
  HELICS_CORE_TYPE_WEBSOCKET* = (14).HelicsCoreType
  HELICS_CORE_TYPE_INPROC* = (18).HelicsCoreType
  HELICS_CORE_TYPE_NULL* = (66).HelicsCoreType
  HELICS_DATA_TYPE_STRING* = (0).HelicsDataType
  HELICS_DATA_TYPE_DOUBLE* = (1).HelicsDataType
  HELICS_DATA_TYPE_INT* = (2).HelicsDataType
  HELICS_DATA_TYPE_COMPLEX* = (3).HelicsDataType
  HELICS_DATA_TYPE_VECTOR* = (4).HelicsDataType
  HELICS_DATA_TYPE_COMPLEX_VECTOR* = (5).HelicsDataType
  HELICS_DATA_TYPE_NAMED_POINT* = (6).HelicsDataType
  HELICS_DATA_TYPE_BOOLEAN* = (7).HelicsDataType
  HELICS_DATA_TYPE_TIME* = (8).HelicsDataType
  HELICS_DATA_TYPE_RAW* = (25).HelicsDataType
  HELICS_DATA_TYPE_MULTI* = (33).HelicsDataType
  HELICS_DATA_TYPE_ANY* = (25262).HelicsDataType
  HELICS_FLAG_OBSERVER* = (0).HelicsFederateFlags
  HELICS_FLAG_UNINTERRUPTIBLE* = (1).HelicsFederateFlags
  HELICS_FLAG_INTERRUPTIBLE* = (2).HelicsFederateFlags
  HELICS_FLAG_SOURCE_ONLY* = (4).HelicsFederateFlags
  HELICS_FLAG_ONLY_TRANSMIT_ON_CHANGE* = (6).HelicsFederateFlags
  HELICS_FLAG_ONLY_UPDATE_ON_CHANGE* = (8).HelicsFederateFlags
  HELICS_FLAG_WAIT_FOR_CURRENT_TIME_UPDATE* = (10).HelicsFederateFlags
  HELICS_FLAG_RESTRICTIVE_TIME_POLICY* = (11).HelicsFederateFlags
  HELICS_FLAG_ROLLBACK* = (12).HelicsFederateFlags
  HELICS_FLAG_FORWARD_COMPUTE* = (14).HelicsFederateFlags
  HELICS_FLAG_REALTIME* = (16).HelicsFederateFlags
  HELICS_FLAG_SINGLE_THREAD_FEDERATE* = (27).HelicsFederateFlags
  HELICS_FLAG_SLOW_RESPONDING* = (29).HelicsFederateFlags
  HELICS_FLAG_DELAY_INIT_ENTRY* = (45).HelicsFederateFlags
  HELICS_FLAG_ENABLE_INIT_ENTRY* = (47).HelicsFederateFlags
  HELICS_FLAG_IGNORE_TIME_MISMATCH_WARNINGS* = (67).HelicsFederateFlags
  HELICS_FLAG_TERMINATE_ON_ERROR* = (72).HelicsFederateFlags
  HELICS_LOG_LEVEL_NO_PRINT* = (-1).HelicsLogLevels
  HELICS_LOG_LEVEL_ERROR* = (0).HelicsLogLevels
  HELICS_LOG_LEVEL_WARNING* = (1).HelicsLogLevels
  HELICS_LOG_LEVEL_SUMMARY* = (2).HelicsLogLevels
  HELICS_LOG_LEVEL_CONNECTIONS* = (3).HelicsLogLevels
  HELICS_LOG_LEVEL_INTERFACES* = (4).HelicsLogLevels
  HELICS_LOG_LEVEL_TIMING* = (5).HelicsLogLevels
  HELICS_LOG_LEVEL_DATA* = (6).HelicsLogLevels
  HELICS_LOG_LEVEL_TRACE* = (7).HelicsLogLevels
  HELICS_ERROR_FATAL* = (-404).HelicsErrorTypes
  HELICS_ERROR_EXTERNAL_TYPE* = (-203).HelicsErrorTypes
  HELICS_ERROR_OTHER* = (-101).HelicsErrorTypes
  HELICS_ERROR_INSUFFICIENT_SPACE* = (-18).HelicsErrorTypes
  HELICS_ERROR_EXECUTION_FAILURE* = (-14).HelicsErrorTypes
  HELICS_ERROR_INVALID_FUNCTION_CALL* = (-10).HelicsErrorTypes
  HELICS_ERROR_INVALID_STATE_TRANSITION* = (-9).HelicsErrorTypes
  HELICS_WARNING* = (-8).HelicsErrorTypes
  HELICS_ERROR_SYSTEM_FAILURE* = (-6).HelicsErrorTypes
  HELICS_ERROR_DISCARD* = (-5).HelicsErrorTypes
  HELICS_ERROR_INVALID_ARGUMENT* = (-4).HelicsErrorTypes
  HELICS_ERROR_INVALID_OBJECT* = (-3).HelicsErrorTypes
  HELICS_ERROR_CONNECTION_FAILURE* = (-2).HelicsErrorTypes
  HELICS_ERROR_REGISTRATION_FAILURE* = (-1).HelicsErrorTypes
  HELICS_OK* = (0).HelicsErrorTypes
  HELICS_PROPERTY_TIME_DELTA* = (137).HelicsProperties
  HELICS_PROPERTY_TIME_PERIOD* = (140).HelicsProperties
  HELICS_PROPERTY_TIME_OFFSET* = (141).HelicsProperties
  HELICS_PROPERTY_TIME_RT_LAG* = (143).HelicsProperties
  HELICS_PROPERTY_TIME_RT_LEAD* = (144).HelicsProperties
  HELICS_PROPERTY_TIME_RT_TOLERANCE* = (145).HelicsProperties
  HELICS_PROPERTY_TIME_INPUT_DELAY* = (148).HelicsProperties
  HELICS_PROPERTY_TIME_OUTPUT_DELAY* = (150).HelicsProperties
  HELICS_PROPERTY_INT_MAX_ITERATIONS* = (259).HelicsProperties
  HELICS_PROPERTY_INT_LOG_LEVEL* = (271).HelicsProperties
  HELICS_PROPERTY_INT_FILE_LOG_LEVEL* = (272).HelicsProperties
  HELICS_PROPERTY_INT_CONSOLE_LOG_LEVEL* = (274).HelicsProperties
  HELICS_MULTI_INPUT_NO_OP* = (0).HelicsMultiInputMode
  HELICS_MULTI_INPUT_VECTORIZE_OPERATION* = (1).HelicsMultiInputMode
  HELICS_MULTI_INPUT_AND_OPERATION* = (2).HelicsMultiInputMode
  HELICS_MULTI_INPUT_OR_OPERATION* = (3).HelicsMultiInputMode
  HELICS_MULTI_INPUT_SUM_OPERATION* = (4).HelicsMultiInputMode
  HELICS_MULTI_INPUT_DIFF_OPERATION* = (5).HelicsMultiInputMode
  HELICS_MULTI_INPUT_MAX_OPERATION* = (6).HelicsMultiInputMode
  HELICS_MULTI_INPUT_MIN_OPERATION* = (7).HelicsMultiInputMode
  HELICS_MULTI_INPUT_AVERAGE_OPERATION* = (8).HelicsMultiInputMode
  HELICS_HANDLE_OPTION_CONNECTION_REQUIRED* = (397).HelicsHandleOptions
  HELICS_HANDLE_OPTION_CONNECTION_OPTIONAL* = (402).HelicsHandleOptions
  HELICS_HANDLE_OPTION_SINGLE_CONNECTION_ONLY* = (407).HelicsHandleOptions
  HELICS_HANDLE_OPTION_MULTIPLE_CONNECTIONS_ALLOWED* = (409).HelicsHandleOptions
  HELICS_HANDLE_OPTION_BUFFER_DATA* = (411).HelicsHandleOptions
  HELICS_HANDLE_OPTION_STRICT_TYPE_CHECKING* = (414).HelicsHandleOptions
  HELICS_HANDLE_OPTION_IGNORE_UNIT_MISMATCH* = (447).HelicsHandleOptions
  HELICS_HANDLE_OPTION_ONLY_TRANSMIT_ON_CHANGE* = (452).HelicsHandleOptions
  HELICS_HANDLE_OPTION_ONLY_UPDATE_ON_CHANGE* = (454).HelicsHandleOptions
  HELICS_HANDLE_OPTION_IGNORE_INTERRUPTS* = (475).HelicsHandleOptions
  HELICS_HANDLE_OPTION_MULTI_INPUT_HANDLING_METHOD* = (507).HelicsHandleOptions
  HELICS_HANDLE_OPTION_INPUT_PRIORITY_LOCATION* = (510).HelicsHandleOptions
  HELICS_HANDLE_OPTION_CLEAR_PRIORITY_LIST* = (512).HelicsHandleOptions
  HELICS_HANDLE_OPTION_CONNECTIONS* = (522).HelicsHandleOptions
  HELICS_FILTER_TYPE_CUSTOM* = (0).HelicsFilterType
  HELICS_FILTER_TYPE_DELAY* = (1).HelicsFilterType
  HELICS_FILTER_TYPE_RANDOM_DELAY* = (2).HelicsFilterType
  HELICS_FILTER_TYPE_RANDOM_DROP* = (3).HelicsFilterType
  HELICS_FILTER_TYPE_REROUTE* = (4).HelicsFilterType
  HELICS_FILTER_TYPE_CLONE* = (5).HelicsFilterType
  HELICS_FILTER_TYPE_FIREWALL* = (6).HelicsFilterType
  HELICS_ITERATION_REQUEST_NO_ITERATION* = 0.HelicsIterationRequest
  HELICS_ITERATION_REQUEST_FORCE_ITERATION* = 1.HelicsIterationRequest
  HELICS_ITERATION_REQUEST_ITERATE_IF_NEEDED* = 2.HelicsIterationRequest
  HELICS_ITERATION_RESULT_NEXT_STEP* = 0.HelicsIterationResult
  HELICS_ITERATION_RESULT_ERROR* = 1.HelicsIterationResult
  HELICS_ITERATION_RESULT_HALTED* = 2.HelicsIterationResult
  HELICS_ITERATION_RESULT_ITERATING* = 3.HelicsIterationResult
  HELICS_STATE_STARTUP* = (0).HelicsFederateState
  HELICS_STATE_INITIALIZATION* = 1.HelicsFederateState
  HELICS_STATE_EXECUTION* = 2.HelicsFederateState
  HELICS_STATE_FINALIZE* = 3.HelicsFederateState
  HELICS_STATE_ERROR* = 4.HelicsFederateState
  HELICS_STATE_PENDING_INIT* = 5.HelicsFederateState
  HELICS_STATE_PENDING_EXEC* = 6.HelicsFederateState
  HELICS_STATE_PENDING_TIME* = 7.HelicsFederateState
  HELICS_STATE_PENDING_ITERATIVE_TIME* = 8.HelicsFederateState
  HELICS_STATE_PENDING_FINALIZE* = 9.HelicsFederateState

type
  HelicsBool = bool

  # *
  #  * opaque object representing an input
  #
  HelicsInput* = pointer

  # *
  #  * opaque object representing a publication
  #
  HelicsPublication* = pointer

  # *
  #  * opaque object representing an endpoint
  #
  HelicsEndpoint* = pointer

  # *
  #  * opaque object representing a filter
  #
  HelicsFilter* = pointer

  # *
  #  * opaque object representing a core
  #
  HelicsCore* = pointer

  # *
  #  * opaque object representing a broker
  #
  HelicsBroker* = pointer

  # *
  #  * opaque object representing a federate
  #
  HelicsFederate* = pointer

  # *
  #  * opaque object representing a filter info object structure
  #
  HelicsFederateInfo* = pointer

  # *
  #  * opaque object representing a query
  #
  HelicsQuery* = pointer

  # *
  #  * opaque object representing a message
  #
  HelicsMessageObject* = pointer

  # *
  #  * time definition used in the C interface to helics
  #
  HelicsTime* = cdouble

  # *
  #  *  structure defining a basic complex type
  #
  HelicsComplex* {.bycopy.} = object
    real*: cdouble
    imag*: cdouble

  # *
  #  *  Message_t mapped to a c compatible structure
  #  *
  #  * @details use of this structure is deprecated in HELICS 2.5 and removed in HELICS 3.0
  #
  HelicsMessage* {.bycopy.} = object
    time*: HelicsTime
    data*: cstring
    length*: int64
    messageID*: int32
    flags*: int16
    original_source*: cstring
    source*: cstring
    dest*: cstring
    original_dest*: cstring

  # *
  #  * helics error object
  #  *
  #  * if error_code==0 there is no error, if error_code!=0 there is an error and message will contain a string,
  #  * otherwise it will be an empty string
  #
  HelicsError* {.bycopy.} = object
    error_code*: int32
    message*: cstring


type
  ProcWrapper[T: proc] = object
    sym: T
    loaded: bool

  HelicsLibrary = ref object
    lib: LibHandle
    m_helicsGetVersion: ProcWrapper[proc (): cstring {.cdecl.}]
    m_helicsGetBuildFlags: ProcWrapper[proc (): cstring {.cdecl.}]
    m_helicsGetCompilerVersion: ProcWrapper[proc (): cstring {.cdecl.}]
    m_helicsErrorInitialize: ProcWrapper[proc (): HelicsError {.cdecl.}]
    m_helicsErrorClear: ProcWrapper[proc (err: ptr HelicsError) {.cdecl.}]
    m_helicsIsCoreTypeAvailable: ProcWrapper[proc (`type`: cstring): HelicsBool {.cdecl.}]
    m_helicsCreateCore: ProcWrapper[proc (`type`: cstring, name: cstring, initString: cstring, err: ptr HelicsError): HelicsCore {.cdecl.}]
    m_helicsCreateCoreFromArgs: ProcWrapper[proc (`type`: cstring, name: cstring, argc: cint, argv: ptr cstring, err: ptr HelicsError): HelicsCore {.cdecl.}]
    m_helicsCoreClone: ProcWrapper[proc (core: HelicsCore, err: ptr HelicsError): HelicsCore {.cdecl.}]
    m_helicsCoreIsValid: ProcWrapper[proc (core: HelicsCore): HelicsBool {.cdecl.}]
    m_helicsCreateBroker: ProcWrapper[proc (`type`: cstring, name: cstring, initString: cstring, err: ptr HelicsError): HelicsBroker {.cdecl.}]
    m_helicsCreateBrokerFromArgs: ProcWrapper[proc (`type`: cstring, name: cstring, argc: cint, argv: ptr cstring, err: ptr HelicsError): HelicsBroker {.cdecl.}]
    m_helicsBrokerClone: ProcWrapper[proc (broker: HelicsBroker, err: ptr HelicsError): HelicsBroker {.cdecl.}]
    m_helicsBrokerIsValid: ProcWrapper[proc (broker: HelicsBroker): HelicsBool {.cdecl.}]
    m_helicsBrokerIsConnected: ProcWrapper[proc (broker: HelicsBroker): HelicsBool {.cdecl.}]
    m_helicsBrokerDataLink: ProcWrapper[proc (broker: HelicsBroker, source: cstring, target: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsBrokerAddSourceFilterToEndpoint: ProcWrapper[proc (broker: HelicsBroker, filter: cstring, endpoint: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsBrokerAddDestinationFilterToEndpoint: ProcWrapper[proc (broker: HelicsBroker, filter: cstring, endpoint: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsBrokerMakeConnections: ProcWrapper[proc (broker: HelicsBroker, file: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsCoreWaitForDisconnect: ProcWrapper[proc (core: HelicsCore, msToWait: cint, err: ptr HelicsError): HelicsBool {.cdecl.}]
    m_helicsBrokerWaitForDisconnect: ProcWrapper[proc (broker: HelicsBroker, msToWait: cint, err: ptr HelicsError): HelicsBool {.cdecl.}]
    m_helicsCoreIsConnected: ProcWrapper[proc (core: HelicsCore): HelicsBool {.cdecl.}]
    m_helicsCoreDataLink: ProcWrapper[proc (core: HelicsCore, source: cstring, target: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsCoreAddSourceFilterToEndpoint: ProcWrapper[proc (core: HelicsCore, filter: cstring, endpoint: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsCoreAddDestinationFilterToEndpoint: ProcWrapper[proc (core: HelicsCore, filter: cstring, endpoint: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsCoreMakeConnections: ProcWrapper[proc (core: HelicsCore, file: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsBrokerGetIdentifier: ProcWrapper[proc (broker: HelicsBroker): cstring {.cdecl.}]
    m_helicsCoreGetIdentifier: ProcWrapper[proc (core: HelicsCore): cstring {.cdecl.}]
    m_helicsBrokerGetAddress: ProcWrapper[proc (broker: HelicsBroker): cstring {.cdecl.}]
    m_helicsCoreGetAddress: ProcWrapper[proc (core: HelicsCore): cstring {.cdecl.}]
    m_helicsCoreSetReadyToInit: ProcWrapper[proc (core: HelicsCore, err: ptr HelicsError) {.cdecl.}]
    m_helicsCoreConnect: ProcWrapper[proc (core: HelicsCore, err: ptr HelicsError): HelicsBool {.cdecl.}]
    m_helicsCoreDisconnect: ProcWrapper[proc (core: HelicsCore, err: ptr HelicsError) {.cdecl.}]
    m_helicsGetFederateByName: ProcWrapper[proc (fedName: cstring, err: ptr HelicsError): HelicsFederate {.cdecl.}]
    m_helicsBrokerDisconnect: ProcWrapper[proc (broker: HelicsBroker, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateDestroy: ProcWrapper[proc (fed: HelicsFederate) {.cdecl.}]
    m_helicsBrokerDestroy: ProcWrapper[proc (broker: HelicsBroker) {.cdecl.}]
    m_helicsCoreDestroy: ProcWrapper[proc (core: HelicsCore) {.cdecl.}]
    m_helicsCoreFree: ProcWrapper[proc (core: HelicsCore) {.cdecl.}]
    m_helicsBrokerFree: ProcWrapper[proc (broker: HelicsBroker) {.cdecl.}]
    m_helicsCreateValueFederate: ProcWrapper[proc (fedName: cstring, fi: HelicsFederateInfo, err: ptr HelicsError): HelicsFederate {.cdecl.}]
    m_helicsCreateValueFederateFromConfig: ProcWrapper[proc (configFile: cstring, err: ptr HelicsError): HelicsFederate {.cdecl.}]
    m_helicsCreateMessageFederate: ProcWrapper[proc (fedName: cstring, fi: HelicsFederateInfo, err: ptr HelicsError): HelicsFederate {.cdecl.}]
    m_helicsCreateMessageFederateFromConfig: ProcWrapper[proc (configFile: cstring, err: ptr HelicsError): HelicsFederate {.cdecl.}]
    m_helicsCreateCombinationFederate: ProcWrapper[proc (fedName: cstring, fi: HelicsFederateInfo, err: ptr HelicsError): HelicsFederate {.cdecl.}]
    m_helicsCreateCombinationFederateFromConfig: ProcWrapper[proc (configFile: cstring, err: ptr HelicsError): HelicsFederate {.cdecl.}]
    m_helicsFederateClone: ProcWrapper[proc (fed: HelicsFederate, err: ptr HelicsError): HelicsFederate {.cdecl.}]
    m_helicsCreateFederateInfo: ProcWrapper[proc (): HelicsFederateInfo {.cdecl.}]
    m_helicsFederateInfoClone: ProcWrapper[proc (fi: HelicsFederateInfo, err: ptr HelicsError): HelicsFederateInfo {.cdecl.}]
    m_helicsFederateInfoLoadFromArgs: ProcWrapper[proc (fi: HelicsFederateInfo, argc: cint, argv: ptr cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateInfoFree: ProcWrapper[proc (fi: HelicsFederateInfo) {.cdecl.}]
    m_helicsFederateIsValid: ProcWrapper[proc (fed: HelicsFederate): HelicsBool {.cdecl.}]
    m_helicsFederateInfoSetCoreName: ProcWrapper[proc (fi: HelicsFederateInfo, corename: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateInfoSetCoreInitString: ProcWrapper[proc (fi: HelicsFederateInfo, coreInit: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateInfoSetBrokerInitString: ProcWrapper[proc (fi: HelicsFederateInfo, brokerInit: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateInfoSetCoreType: ProcWrapper[proc (fi: HelicsFederateInfo, coretype: cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateInfoSetCoreTypeFromString: ProcWrapper[proc (fi: HelicsFederateInfo, coretype: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateInfoSetBroker: ProcWrapper[proc (fi: HelicsFederateInfo, broker: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateInfoSetBrokerKey: ProcWrapper[proc (fi: HelicsFederateInfo, brokerkey: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateInfoSetBrokerPort: ProcWrapper[proc (fi: HelicsFederateInfo, brokerPort: cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateInfoSetLocalPort: ProcWrapper[proc (fi: HelicsFederateInfo, localPort: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsGetPropertyIndex: ProcWrapper[proc (val: cstring): cint {.cdecl.}]
    m_helicsGetFlagIndex: ProcWrapper[proc (val: cstring): cint {.cdecl.}]
    m_helicsGetOptionIndex: ProcWrapper[proc (val: cstring): cint {.cdecl.}]
    m_helicsGetOptionValue: ProcWrapper[proc (val: cstring): cint {.cdecl.}]
    m_helicsFederateInfoSetFlagOption: ProcWrapper[proc (fi: HelicsFederateInfo, flag: cint, value: HelicsBool, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateInfoSetSeparator: ProcWrapper[proc (fi: HelicsFederateInfo, separator: cchar, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateInfoSetTimeProperty: ProcWrapper[proc (fi: HelicsFederateInfo, timeProperty: cint, propertyValue: HelicsTime, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateInfoSetIntegerProperty: ProcWrapper[proc (fi: HelicsFederateInfo, intProperty: cint, propertyValue: cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateRegisterInterfaces: ProcWrapper[proc (fed: HelicsFederate, file: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateGlobalError: ProcWrapper[proc (fed: HelicsFederate, error_code: cint, error_string: cstring) {.cdecl.}]
    m_helicsFederateLocalError: ProcWrapper[proc (fed: HelicsFederate, error_code: cint, error_string: cstring) {.cdecl.}]
    m_helicsFederateFinalize: ProcWrapper[proc (fed: HelicsFederate, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateFinalizeAsync: ProcWrapper[proc (fed: HelicsFederate, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateFinalizeComplete: ProcWrapper[proc (fed: HelicsFederate, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateFree: ProcWrapper[proc (fed: HelicsFederate) {.cdecl.}]
    m_helicsCloseLibrary: ProcWrapper[proc () {.cdecl.}]
    m_helicsFederateEnterInitializingMode: ProcWrapper[proc (fed: HelicsFederate, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateEnterInitializingModeAsync: ProcWrapper[proc (fed: HelicsFederate, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateIsAsyncOperationCompleted: ProcWrapper[proc (fed: HelicsFederate, err: ptr HelicsError): HelicsBool {.cdecl.}]
    m_helicsFederateEnterInitializingModeComplete: ProcWrapper[proc (fed: HelicsFederate, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateEnterExecutingMode: ProcWrapper[proc (fed: HelicsFederate, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateEnterExecutingModeAsync: ProcWrapper[proc (fed: HelicsFederate, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateEnterExecutingModeComplete: ProcWrapper[proc (fed: HelicsFederate, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateEnterExecutingModeIterative: ProcWrapper[proc (fed: HelicsFederate, iterate: HelicsIterationRequest, err: ptr HelicsError): HelicsIterationResult {.cdecl.}]
    m_helicsFederateEnterExecutingModeIterativeAsync: ProcWrapper[proc (fed: HelicsFederate, iterate: HelicsIterationRequest, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateEnterExecutingModeIterativeComplete: ProcWrapper[proc (fed: HelicsFederate, err: ptr HelicsError): HelicsIterationResult {.cdecl.}]
    m_helicsFederateGetState: ProcWrapper[proc (fed: HelicsFederate, err: ptr HelicsError): HelicsFederateState {.cdecl.}]
    m_helicsFederateGetCoreObject: ProcWrapper[proc (fed: HelicsFederate, err: ptr HelicsError): HelicsCore {.cdecl.}]
    m_helicsFederateRequestTime: ProcWrapper[proc (fed: HelicsFederate, requestTime: HelicsTime, err: ptr HelicsError): HelicsTime {.cdecl.}]
    m_helicsFederateRequestTimeAdvance: ProcWrapper[proc (fed: HelicsFederate, timeDelta: HelicsTime, err: ptr HelicsError): HelicsTime {.cdecl.}]
    m_helicsFederateRequestNextStep: ProcWrapper[proc (fed: HelicsFederate, err: ptr HelicsError): HelicsTime {.cdecl.}]
    m_helicsFederateRequestTimeIterative: ProcWrapper[proc (fed: HelicsFederate, requestTime: HelicsTime, iterate: HelicsIterationRequest, outIteration: ptr HelicsIterationResult, err: ptr HelicsError): HelicsTime {.cdecl.}]
    m_helicsFederateRequestTimeAsync: ProcWrapper[proc (fed: HelicsFederate, requestTime: HelicsTime, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateRequestTimeComplete: ProcWrapper[proc (fed: HelicsFederate, err: ptr HelicsError): HelicsTime {.cdecl.}]
    m_helicsFederateRequestTimeIterativeAsync: ProcWrapper[proc (fed: HelicsFederate, requestTime: HelicsTime, iterate: HelicsIterationRequest, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateRequestTimeIterativeComplete: ProcWrapper[proc (fed: HelicsFederate, outIterate: ptr HelicsIterationResult, err: ptr HelicsError): HelicsTime {.cdecl.}]
    m_helicsFederateGetName: ProcWrapper[proc (fed: HelicsFederate): cstring {.cdecl.}]
    m_helicsFederateSetTimeProperty: ProcWrapper[proc (fed: HelicsFederate, timeProperty: cint, time: HelicsTime, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateSetFlagOption: ProcWrapper[proc (fed: HelicsFederate, flag: cint, flagValue: HelicsBool, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateSetSeparator: ProcWrapper[proc (fed: HelicsFederate, separator: cchar, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateSetIntegerProperty: ProcWrapper[proc (fed: HelicsFederate, intProperty: cint, propertyVal: cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateGetTimeProperty: ProcWrapper[proc (fed: HelicsFederate, timeProperty: cint, err: ptr HelicsError): HelicsTime {.cdecl.}]
    m_helicsFederateGetFlagOption: ProcWrapper[proc (fed: HelicsFederate, flag: cint, err: ptr HelicsError): HelicsBool {.cdecl.}]
    m_helicsFederateGetIntegerProperty: ProcWrapper[proc (fed: HelicsFederate, intProperty: cint, err: ptr HelicsError): cint {.cdecl.}]
    m_helicsFederateGetCurrentTime: ProcWrapper[proc (fed: HelicsFederate, err: ptr HelicsError): HelicsTime {.cdecl.}]
    m_helicsFederateSetGlobal: ProcWrapper[proc (fed: HelicsFederate, valueName: cstring, value: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateAddDependency: ProcWrapper[proc (fed: HelicsFederate, fedName: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateSetLogFile: ProcWrapper[proc (fed: HelicsFederate, logFile: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateLogErrorMessage: ProcWrapper[proc (fed: HelicsFederate, logmessage: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateLogWarningMessage: ProcWrapper[proc (fed: HelicsFederate, logmessage: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateLogInfoMessage: ProcWrapper[proc (fed: HelicsFederate, logmessage: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateLogDebugMessage: ProcWrapper[proc (fed: HelicsFederate, logmessage: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateLogLevelMessage: ProcWrapper[proc (fed: HelicsFederate, loglevel: cint, logmessage: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsCoreSetGlobal: ProcWrapper[proc (core: HelicsCore, valueName: cstring, value: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsBrokerSetGlobal: ProcWrapper[proc (broker: HelicsBroker, valueName: cstring, value: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsCoreSetLogFile: ProcWrapper[proc (core: HelicsCore, logFileName: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsBrokerSetLogFile: ProcWrapper[proc (broker: HelicsBroker, logFileName: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsCreateQuery: ProcWrapper[proc (target: cstring, query: cstring): HelicsQuery {.cdecl.}]
    m_helicsQueryExecute: ProcWrapper[proc (query: HelicsQuery, fed: HelicsFederate, err: ptr HelicsError): cstring {.cdecl.}]
    m_helicsQueryCoreExecute: ProcWrapper[proc (query: HelicsQuery, core: HelicsCore, err: ptr HelicsError): cstring {.cdecl.}]
    m_helicsQueryBrokerExecute: ProcWrapper[proc (query: HelicsQuery, broker: HelicsBroker, err: ptr HelicsError): cstring {.cdecl.}]
    m_helicsQueryExecuteAsync: ProcWrapper[proc (query: HelicsQuery, fed: HelicsFederate, err: ptr HelicsError) {.cdecl.}]
    m_helicsQueryExecuteComplete: ProcWrapper[proc (query: HelicsQuery, err: ptr HelicsError): cstring {.cdecl.}]
    m_helicsQueryIsCompleted: ProcWrapper[proc (query: HelicsQuery): HelicsBool {.cdecl.}]
    m_helicsQuerySetTarget: ProcWrapper[proc (query: HelicsQuery, target: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsQuerySetQueryString: ProcWrapper[proc (query: HelicsQuery, queryString: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsQueryFree: ProcWrapper[proc (query: HelicsQuery) {.cdecl.}]
    m_helicsCleanupLibrary: ProcWrapper[proc () {.cdecl.}]
    m_helicsFederateRegisterEndpoint: ProcWrapper[proc (fed: HelicsFederate, name: cstring, `type`: cstring, err: ptr HelicsError): HelicsEndpoint {.cdecl.}]
    m_helicsFederateRegisterGlobalEndpoint: ProcWrapper[proc (fed: HelicsFederate, name: cstring, `type`: cstring, err: ptr HelicsError): HelicsEndpoint {.cdecl.}]
    m_helicsFederateGetEndpoint: ProcWrapper[proc (fed: HelicsFederate, name: cstring, err: ptr HelicsError): HelicsEndpoint {.cdecl.}]
    m_helicsFederateGetEndpointByIndex: ProcWrapper[proc (fed: HelicsFederate, index: cint, err: ptr HelicsError): HelicsEndpoint {.cdecl.}]
    m_helicsEndpointIsValid: ProcWrapper[proc (endpoint: HelicsEndpoint): HelicsBool {.cdecl.}]
    m_helicsEndpointSetDefaultDestination: ProcWrapper[proc (endpoint: HelicsEndpoint, dest: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsEndpointGetDefaultDestination: ProcWrapper[proc (endpoint: HelicsEndpoint): cstring {.cdecl.}]
    m_helicsEndpointSendMessageRaw: ProcWrapper[proc (endpoint: HelicsEndpoint, dest: cstring, data: pointer, inputDataLength: cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsEndpointSendEventRaw: ProcWrapper[proc (endpoint: HelicsEndpoint, dest: cstring, data: pointer, inputDataLength: cint, time: HelicsTime, err: ptr HelicsError) {.cdecl.}]
    m_helicsEndpointSendMessage: ProcWrapper[proc (endpoint: HelicsEndpoint, message: ptr HelicsMessage, err: ptr HelicsError) {.cdecl.}]
    m_helicsEndpointSendMessageObject: ProcWrapper[proc (endpoint: HelicsEndpoint, message: HelicsMessageObject, err: ptr HelicsError) {.cdecl.}]
    m_helicsEndpointSendMessageObjectZeroCopy: ProcWrapper[proc (endpoint: HelicsEndpoint, message: HelicsMessageObject, err: ptr HelicsError) {.cdecl.}]
    m_helicsEndpointSubscribe: ProcWrapper[proc (endpoint: HelicsEndpoint, key: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederateHasMessage: ProcWrapper[proc (fed: HelicsFederate): HelicsBool {.cdecl.}]
    m_helicsEndpointHasMessage: ProcWrapper[proc (endpoint: HelicsEndpoint): HelicsBool {.cdecl.}]
    m_helicsFederatePendingMessages: ProcWrapper[proc (fed: HelicsFederate): cint {.cdecl.}]
    m_helicsEndpointPendingMessages: ProcWrapper[proc (endpoint: HelicsEndpoint): cint {.cdecl.}]
    m_helicsEndpointGetMessage: ProcWrapper[proc (endpoint: HelicsEndpoint): HelicsMessage {.cdecl.}]
    m_helicsEndpointGetMessageObject: ProcWrapper[proc (endpoint: HelicsEndpoint): HelicsMessageObject {.cdecl.}]
    m_helicsEndpointCreateMessageObject: ProcWrapper[proc (endpoint: HelicsEndpoint, err: ptr HelicsError): HelicsMessageObject {.cdecl.}]
    m_helicsFederateGetMessage: ProcWrapper[proc (fed: HelicsFederate): HelicsMessage {.cdecl.}]
    m_helicsFederateGetMessageObject: ProcWrapper[proc (fed: HelicsFederate): HelicsMessageObject {.cdecl.}]
    m_helicsFederateCreateMessageObject: ProcWrapper[proc (fed: HelicsFederate, err: ptr HelicsError): HelicsMessageObject {.cdecl.}]
    m_helicsFederateClearMessages: ProcWrapper[proc (fed: HelicsFederate) {.cdecl.}]
    m_helicsEndpointClearMessages: ProcWrapper[proc (endpoint: HelicsEndpoint) {.cdecl.}]
    m_helicsEndpointGetName: ProcWrapper[proc (endpoint: HelicsEndpoint): cstring {.cdecl.}]
    m_helicsFederateGetEndpointCount: ProcWrapper[proc (fed: HelicsFederate): cint {.cdecl.}]
    m_helicsEndpointGetInfo: ProcWrapper[proc (`end`: HelicsEndpoint): cstring {.cdecl.}]
    m_helicsEndpointSetInfo: ProcWrapper[proc (`end`: HelicsEndpoint, info: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsEndpointSetOption: ProcWrapper[proc (`end`: HelicsEndpoint, option: cint, value: cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsEndpointGetOption: ProcWrapper[proc (`end`: HelicsEndpoint, option: cint): cint {.cdecl.}]
    m_helicsMessageGetSource: ProcWrapper[proc (message: HelicsMessageObject): cstring {.cdecl.}]
    m_helicsMessageGetDestination: ProcWrapper[proc (message: HelicsMessageObject): cstring {.cdecl.}]
    m_helicsMessageGetOriginalSource: ProcWrapper[proc (message: HelicsMessageObject): cstring {.cdecl.}]
    m_helicsMessageGetOriginalDestination: ProcWrapper[proc (message: HelicsMessageObject): cstring {.cdecl.}]
    m_helicsMessageGetTime: ProcWrapper[proc (message: HelicsMessageObject): HelicsTime {.cdecl.}]
    m_helicsMessageGetString: ProcWrapper[proc (message: HelicsMessageObject): cstring {.cdecl.}]
    m_helicsMessageGetMessageID: ProcWrapper[proc (message: HelicsMessageObject): cint {.cdecl.}]
    m_helicsMessageCheckFlag: ProcWrapper[proc (message: HelicsMessageObject, flag: cint): HelicsBool {.cdecl.}]
    m_helicsMessageGetRawDataSize: ProcWrapper[proc (message: HelicsMessageObject): cint {.cdecl.}]
    m_helicsMessageGetRawData: ProcWrapper[proc (message: HelicsMessageObject, data: pointer, maxMessagelen: cint, actualSize: ptr cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsMessageGetRawDataPointer: ProcWrapper[proc (message: HelicsMessageObject): pointer {.cdecl.}]
    m_helicsMessageIsValid: ProcWrapper[proc (message: HelicsMessageObject): HelicsBool {.cdecl.}]
    m_helicsMessageSetSource: ProcWrapper[proc (message: HelicsMessageObject, src: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsMessageSetDestination: ProcWrapper[proc (message: HelicsMessageObject, dest: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsMessageSetOriginalSource: ProcWrapper[proc (message: HelicsMessageObject, src: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsMessageSetOriginalDestination: ProcWrapper[proc (message: HelicsMessageObject, dest: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsMessageSetTime: ProcWrapper[proc (message: HelicsMessageObject, time: HelicsTime, err: ptr HelicsError) {.cdecl.}]
    m_helicsMessageResize: ProcWrapper[proc (message: HelicsMessageObject, newSize: cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsMessageReserve: ProcWrapper[proc (message: HelicsMessageObject, reserveSize: cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsMessageSetMessageID: ProcWrapper[proc (message: HelicsMessageObject, messageID: int32, err: ptr HelicsError) {.cdecl.}]
    m_helicsMessageClearFlags: ProcWrapper[proc (message: HelicsMessageObject) {.cdecl.}]
    m_helicsMessageSetFlagOption: ProcWrapper[proc (message: HelicsMessageObject, flag: cint, flagValue: HelicsBool, err: ptr HelicsError) {.cdecl.}]
    m_helicsMessageSetString: ProcWrapper[proc (message: HelicsMessageObject, str: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsMessageSetData: ProcWrapper[proc (message: HelicsMessageObject, data: pointer, inputDataLength: cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsMessageAppendData: ProcWrapper[proc (message: HelicsMessageObject, data: pointer, inputDataLength: cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsMessageCopy: ProcWrapper[proc (source_message: HelicsMessageObject, dest_message: HelicsMessageObject, err: ptr HelicsError) {.cdecl.}]
    m_helicsMessageClone: ProcWrapper[proc (message: HelicsMessageObject, err: ptr HelicsError): HelicsMessageObject {.cdecl.}]
    m_helicsMessageFree: ProcWrapper[proc (message: HelicsMessageObject) {.cdecl.}]
    m_helicsFederateRegisterFilter: ProcWrapper[proc (fed: HelicsFederate, `type`: HelicsFilterType, name: cstring, err: ptr HelicsError): HelicsFilter {.cdecl.}]
    m_helicsFederateRegisterGlobalFilter: ProcWrapper[proc (fed: HelicsFederate, `type`: HelicsFilterType, name: cstring, err: ptr HelicsError): HelicsFilter {.cdecl.}]
    m_helicsFederateRegisterCloningFilter: ProcWrapper[proc (fed: HelicsFederate, name: cstring, err: ptr HelicsError): HelicsFilter {.cdecl.}]
    m_helicsFederateRegisterGlobalCloningFilter: ProcWrapper[proc (fed: HelicsFederate, name: cstring, err: ptr HelicsError): HelicsFilter {.cdecl.}]
    m_helicsCoreRegisterFilter: ProcWrapper[proc (core: HelicsCore, `type`: HelicsFilterType, name: cstring, err: ptr HelicsError): HelicsFilter {.cdecl.}]
    m_helicsCoreRegisterCloningFilter: ProcWrapper[proc (core: HelicsCore, name: cstring, err: ptr HelicsError): HelicsFilter {.cdecl.}]
    m_helicsFederateGetFilterCount: ProcWrapper[proc (fed: HelicsFederate): cint {.cdecl.}]
    m_helicsFederateGetFilter: ProcWrapper[proc (fed: HelicsFederate, name: cstring, err: ptr HelicsError): HelicsFilter {.cdecl.}]
    m_helicsFederateGetFilterByIndex: ProcWrapper[proc (fed: HelicsFederate, index: cint, err: ptr HelicsError): HelicsFilter {.cdecl.}]
    m_helicsFilterIsValid: ProcWrapper[proc (filt: HelicsFilter): HelicsBool {.cdecl.}]
    m_helicsFilterGetName: ProcWrapper[proc (filt: HelicsFilter): cstring {.cdecl.}]
    m_helicsFilterSet: ProcWrapper[proc (filt: HelicsFilter, prop: cstring, val: cdouble, err: ptr HelicsError) {.cdecl.}]
    m_helicsFilterSetString: ProcWrapper[proc (filt: HelicsFilter, prop: cstring, val: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFilterAddDestinationTarget: ProcWrapper[proc (filt: HelicsFilter, dest: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFilterAddSourceTarget: ProcWrapper[proc (filt: HelicsFilter, source: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFilterAddDeliveryEndpoint: ProcWrapper[proc (filt: HelicsFilter, deliveryEndpoint: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFilterRemoveTarget: ProcWrapper[proc (filt: HelicsFilter, target: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFilterRemoveDeliveryEndpoint: ProcWrapper[proc (filt: HelicsFilter, deliveryEndpoint: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFilterGetInfo: ProcWrapper[proc (filt: HelicsFilter): cstring {.cdecl.}]
    m_helicsFilterSetInfo: ProcWrapper[proc (filt: HelicsFilter, info: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFilterSetOption: ProcWrapper[proc (filt: HelicsFilter, option: cint, value: cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsFilterGetOption: ProcWrapper[proc (filt: HelicsFilter, option: cint): cint {.cdecl.}]
    m_helicsFederateRegisterSubscription: ProcWrapper[proc (fed: HelicsFederate, key: cstring, units: cstring, err: ptr HelicsError): HelicsInput {.cdecl.}]
    m_helicsFederateRegisterPublication: ProcWrapper[proc (fed: HelicsFederate, key: cstring, `type`: HelicsDataType, units: cstring, err: ptr HelicsError): HelicsPublication {.cdecl.}]
    m_helicsFederateRegisterTypePublication: ProcWrapper[proc (fed: HelicsFederate, key: cstring, `type`: cstring, units: cstring, err: ptr HelicsError): HelicsPublication {.cdecl.}]
    m_helicsFederateRegisterGlobalPublication: ProcWrapper[proc (fed: HelicsFederate, key: cstring, `type`: HelicsDataType, units: cstring, err: ptr HelicsError): HelicsPublication {.cdecl.}]
    m_helicsFederateRegisterGlobalTypePublication: ProcWrapper[proc (fed: HelicsFederate, key: cstring, `type`: cstring, units: cstring, err: ptr HelicsError): HelicsPublication {.cdecl.}]
    m_helicsFederateRegisterInput: ProcWrapper[proc (fed: HelicsFederate, key: cstring, `type`: HelicsDataType, units: cstring, err: ptr HelicsError): HelicsInput {.cdecl.}]
    m_helicsFederateRegisterTypeInput: ProcWrapper[proc (fed: HelicsFederate, key: cstring, `type`: cstring, units: cstring, err: ptr HelicsError): HelicsInput {.cdecl.}]
    m_helicsFederateRegisterGlobalInput: ProcWrapper[proc (fed: HelicsFederate, key: cstring, `type`: HelicsDataType, units: cstring, err: ptr HelicsError): HelicsPublication {.cdecl.}]
    m_helicsFederateRegisterGlobalTypeInput: ProcWrapper[proc (fed: HelicsFederate, key: cstring, `type`: cstring, units: cstring, err: ptr HelicsError): HelicsPublication {.cdecl.}]
    m_helicsFederateGetPublication: ProcWrapper[proc (fed: HelicsFederate, key: cstring, err: ptr HelicsError): HelicsPublication {.cdecl.}]
    m_helicsFederateGetPublicationByIndex: ProcWrapper[proc (fed: HelicsFederate, index: cint, err: ptr HelicsError): HelicsPublication {.cdecl.}]
    m_helicsFederateGetInput: ProcWrapper[proc (fed: HelicsFederate, key: cstring, err: ptr HelicsError): HelicsInput {.cdecl.}]
    m_helicsFederateGetInputByIndex: ProcWrapper[proc (fed: HelicsFederate, index: cint, err: ptr HelicsError): HelicsInput {.cdecl.}]
    m_helicsFederateGetSubscription: ProcWrapper[proc (fed: HelicsFederate, key: cstring, err: ptr HelicsError): HelicsInput {.cdecl.}]
    m_helicsFederateClearUpdates: ProcWrapper[proc (fed: HelicsFederate) {.cdecl.}]
    m_helicsFederateRegisterFromPublicationJSON: ProcWrapper[proc (fed: HelicsFederate, json: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsFederatePublishJSON: ProcWrapper[proc (fed: HelicsFederate, json: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsPublicationIsValid: ProcWrapper[proc (pub: HelicsPublication): HelicsBool {.cdecl.}]
    m_helicsPublicationPublishRaw: ProcWrapper[proc (pub: HelicsPublication, data: pointer, inputDataLength: cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsPublicationPublishString: ProcWrapper[proc (pub: HelicsPublication, str: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsPublicationPublishInteger: ProcWrapper[proc (pub: HelicsPublication, val: int64, err: ptr HelicsError) {.cdecl.}]
    m_helicsPublicationPublishBoolean: ProcWrapper[proc (pub: HelicsPublication, val: HelicsBool, err: ptr HelicsError) {.cdecl.}]
    m_helicsPublicationPublishDouble: ProcWrapper[proc (pub: HelicsPublication, val: cdouble, err: ptr HelicsError) {.cdecl.}]
    m_helicsPublicationPublishTime: ProcWrapper[proc (pub: HelicsPublication, val: HelicsTime, err: ptr HelicsError) {.cdecl.}]
    m_helicsPublicationPublishChar: ProcWrapper[proc (pub: HelicsPublication, val: cchar, err: ptr HelicsError) {.cdecl.}]
    m_helicsPublicationPublishComplex: ProcWrapper[proc (pub: HelicsPublication, real: cdouble, imag: cdouble, err: ptr HelicsError) {.cdecl.}]
    m_helicsPublicationPublishVector: ProcWrapper[proc (pub: HelicsPublication, vectorInput: ptr cdouble, vectorLength: cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsPublicationPublishNamedPoint: ProcWrapper[proc (pub: HelicsPublication, str: cstring, val: cdouble, err: ptr HelicsError) {.cdecl.}]
    m_helicsPublicationAddTarget: ProcWrapper[proc (pub: HelicsPublication, target: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsInputIsValid: ProcWrapper[proc (ipt: HelicsInput): HelicsBool {.cdecl.}]
    m_helicsInputAddTarget: ProcWrapper[proc (ipt: HelicsInput, target: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsInputGetRawValueSize: ProcWrapper[proc (ipt: HelicsInput): cint {.cdecl.}]
    m_helicsInputGetRawValue: ProcWrapper[proc (ipt: HelicsInput, data: pointer, maxDatalen: cint, actualSize: ptr cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsInputGetStringSize: ProcWrapper[proc (ipt: HelicsInput): cint {.cdecl.}]
    m_helicsInputGetString: ProcWrapper[proc (ipt: HelicsInput, outputString: cstring, maxStringLen: cint, actualLength: ptr cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsInputGetInteger: ProcWrapper[proc (ipt: HelicsInput, err: ptr HelicsError): int64 {.cdecl.}]
    m_helicsInputGetBoolean: ProcWrapper[proc (ipt: HelicsInput, err: ptr HelicsError): HelicsBool {.cdecl.}]
    m_helicsInputGetDouble: ProcWrapper[proc (ipt: HelicsInput, err: ptr HelicsError): cdouble {.cdecl.}]
    m_helicsInputGetTime: ProcWrapper[proc (ipt: HelicsInput, err: ptr HelicsError): HelicsTime {.cdecl.}]
    m_helicsInputGetChar: ProcWrapper[proc (ipt: HelicsInput, err: ptr HelicsError): cchar {.cdecl.}]
    m_helicsInputGetComplexObject: ProcWrapper[proc (ipt: HelicsInput, err: ptr HelicsError): HelicsComplex {.cdecl.}]
    m_helicsInputGetComplex: ProcWrapper[proc (ipt: HelicsInput, real: ptr cdouble, imag: ptr cdouble, err: ptr HelicsError) {.cdecl.}]
    m_helicsInputGetVectorSize: ProcWrapper[proc (ipt: HelicsInput): cint {.cdecl.}]
    m_helicsInputGetNamedPoint: ProcWrapper[proc (ipt: HelicsInput, outputString: cstring, maxStringLen: cint, actualLength: ptr cint, val: ptr cdouble, err: ptr HelicsError) {.cdecl.}]
    m_helicsInputSetDefaultRaw: ProcWrapper[proc (ipt: HelicsInput, data: pointer, inputDataLength: cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsInputSetDefaultString: ProcWrapper[proc (ipt: HelicsInput, str: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsInputSetDefaultInteger: ProcWrapper[proc (ipt: HelicsInput, val: int64, err: ptr HelicsError) {.cdecl.}]
    m_helicsInputSetDefaultBoolean: ProcWrapper[proc (ipt: HelicsInput, val: HelicsBool, err: ptr HelicsError) {.cdecl.}]
    m_helicsInputSetDefaultTime: ProcWrapper[proc (ipt: HelicsInput, val: HelicsTime, err: ptr HelicsError) {.cdecl.}]
    m_helicsInputSetDefaultChar: ProcWrapper[proc (ipt: HelicsInput, val: cchar, err: ptr HelicsError) {.cdecl.}]
    m_helicsInputSetDefaultDouble: ProcWrapper[proc (ipt: HelicsInput, val: cdouble, err: ptr HelicsError) {.cdecl.}]
    m_helicsInputSetDefaultComplex: ProcWrapper[proc (ipt: HelicsInput, real: cdouble, imag: cdouble, err: ptr HelicsError) {.cdecl.}]
    m_helicsInputSetDefaultVector: ProcWrapper[proc (ipt: HelicsInput, vectorInput: ptr cdouble, vectorLength: cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsInputSetDefaultNamedPoint: ProcWrapper[proc (ipt: HelicsInput, str: cstring, val: cdouble, err: ptr HelicsError) {.cdecl.}]
    m_helicsInputGetType: ProcWrapper[proc (ipt: HelicsInput): cstring {.cdecl.}]
    m_helicsInputGetPublicationType: ProcWrapper[proc (ipt: HelicsInput): cstring {.cdecl.}]
    m_helicsPublicationGetType: ProcWrapper[proc (pub: HelicsPublication): cstring {.cdecl.}]
    m_helicsInputGetKey: ProcWrapper[proc (ipt: HelicsInput): cstring {.cdecl.}]
    m_helicsSubscriptionGetKey: ProcWrapper[proc (ipt: HelicsInput): cstring {.cdecl.}]
    m_helicsPublicationGetKey: ProcWrapper[proc (pub: HelicsPublication): cstring {.cdecl.}]
    m_helicsInputGetUnits: ProcWrapper[proc (ipt: HelicsInput): cstring {.cdecl.}]
    m_helicsInputGetInjectionUnits: ProcWrapper[proc (ipt: HelicsInput): cstring {.cdecl.}]
    m_helicsInputGetExtractionUnits: ProcWrapper[proc (ipt: HelicsInput): cstring {.cdecl.}]
    m_helicsPublicationGetUnits: ProcWrapper[proc (pub: HelicsPublication): cstring {.cdecl.}]
    m_helicsInputGetInfo: ProcWrapper[proc (inp: HelicsInput): cstring {.cdecl.}]
    m_helicsInputSetInfo: ProcWrapper[proc (inp: HelicsInput, info: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsPublicationGetInfo: ProcWrapper[proc (pub: HelicsPublication): cstring {.cdecl.}]
    m_helicsPublicationSetInfo: ProcWrapper[proc (pub: HelicsPublication, info: cstring, err: ptr HelicsError) {.cdecl.}]
    m_helicsInputGetOption: ProcWrapper[proc (inp: HelicsInput, option: cint): cint {.cdecl.}]
    m_helicsInputSetOption: ProcWrapper[proc (inp: HelicsInput, option: cint, value: cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsPublicationGetOption: ProcWrapper[proc (pub: HelicsPublication, option: cint): cint {.cdecl.}]
    m_helicsPublicationSetOption: ProcWrapper[proc (pub: HelicsPublication, option: cint, val: cint, err: ptr HelicsError) {.cdecl.}]
    m_helicsPublicationSetMinimumChange: ProcWrapper[proc (pub: HelicsPublication, tolerance: cdouble, err: ptr HelicsError) {.cdecl.}]
    m_helicsInputSetMinimumChange: ProcWrapper[proc (inp: HelicsInput, tolerance: cdouble, err: ptr HelicsError) {.cdecl.}]
    m_helicsInputIsUpdated: ProcWrapper[proc (ipt: HelicsInput): HelicsBool {.cdecl.}]
    m_helicsInputLastUpdateTime: ProcWrapper[proc (ipt: HelicsInput): HelicsTime {.cdecl.}]
    m_helicsInputClearUpdate: ProcWrapper[proc (ipt: HelicsInput) {.cdecl.}]
    m_helicsFederateGetPublicationCount: ProcWrapper[proc (fed: HelicsFederate): cint {.cdecl.}]
    m_helicsFederateGetInputCount: ProcWrapper[proc (fed: HelicsFederate): cint {.cdecl.}]

macro loadSym(sym: string): untyped =

  var z = ""
  z.add("m_")
  z.add($(sym))
  return nnkStmtList.newTree(
    nnkIfStmt.newTree(
      nnkElifBranch.newTree(
        nnkDotExpr.newTree(
          nnkDotExpr.newTree(
            nnkDotExpr.newTree(
              newIdentNode("l"),
              newIdentNode(z)
            ),
            newIdentNode("sym")
          ),
          newIdentNode("isNil")
        ),
        nnkStmtList.newTree(
          nnkAsgn.newTree(
            nnkDotExpr.newTree(
              nnkDotExpr.newTree(
                newIdentNode("l"),
                newIdentNode(z)
              ),
              newIdentNode("sym")
            ),
            nnkCast.newTree(
              nnkCall.newTree(
                newIdentNode("typeof"),
                nnkDotExpr.newTree(
                  nnkDotExpr.newTree(
                    newIdentNode("l"),
                    newIdentNode(z)
                  ),
                  newIdentNode("sym")
                )
              ),
              nnkCall.newTree(
                nnkDotExpr.newTree(
                  nnkDotExpr.newTree(
                    newIdentNode("l"),
                    newIdentNode("lib")
                  ),
                  newIdentNode("symAddr")
                ),
                newLit($sym)
              )
            )
          ),
          nnkAsgn.newTree(
            nnkDotExpr.newTree(
              nnkDotExpr.newTree(
                newIdentNode("l"),
                newIdentNode(z)
              ),
              newIdentNode("loaded")
            ),
            newIdentNode("true")
          )
        )
      )
    ),
    nnkLetSection.newTree(
      nnkIdentDefs.newTree(
        newIdentNode("f"),
        newEmptyNode(),
        nnkDotExpr.newTree(
          nnkDotExpr.newTree(
            newIdentNode("l"),
            newIdentNode(z)
          ),
          newIdentNode("sym")
        )
      )
    )

  )

proc helicsGetVersion(l: HelicsLibrary): string =
  loadSym("helicsGetVersion")
  result = $(f())



proc loadHelicsLibrary(path: string): HelicsLibrary =
  result = HelicsLibrary()
  result.lib = loadLib(path)
  if result.lib == nil:
    raise newException(ValueError, "couldn't load library: " & path)

let l = loadHelicsLibrary("./helics_install/lib/libhelicsSharedLib.2.5.2.dylib")
