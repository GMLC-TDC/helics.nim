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

const helics_install_path = getEnv("HELICS_INSTALL")

static:
  putEnv("HELICS_INSTALL", helics_install_path)

when defined(linux):
  block:
    {.passL: """-Wl,-rpath,'""" & helics_install_path & """/lib/'""".}
    {.passL: """-Wl,-rpath,'$ORIGIN'""".}
    {.passL: """-Wl,-rpath,'$ORIGIN/helics_install/lib'""".}
    {.passL: """-Wl,-rpath,'$ORIGIN/lib/'""".}
    {.passL: """-Wl,-rpath,'$ORIGIN/../lib/'""".}
    {.passL: """-Wl,-rpath,'.'""".}
    {.passL: """-Wl,-rpath,'/usr/lib/'""".}
    {.passL: """-Wl,-rpath,'/usr/local/lib/'""".}

when defined(macosx):
  block:
    {.passL: """-Wl,-rpath,'""" & helics_install_path & """/lib/'""".}
    {.passL: """-Wl,-rpath,'@loader_path'""".}
    {.passL: """-Wl,-rpath,'@loader_path/helics_install/lib'""".}
    {.passL: """-Wl,-rpath,'@loader_path/lib/'""".}
    {.passL: """-Wl,-rpath,'@loader_path/../lib/'""".}
    {.passL: """-Wl,-rpath,'@executable_path'""".}
    {.passL: """-Wl,-rpath,'@executable_path/lib/'""".}
    {.passL: """-Wl,-rpath,'@executable_path/helics_install/lib'""".}
    {.passL: """-Wl,-rpath,'@executable_path/../lib/'""".}
    {.passL: """-Wl,-rpath,'.'""".}
    {.passL: """-Wl,-rpath,'/usr/lib/'""".}
    {.passL: """-Wl,-rpath,'/usr/local/lib/'""".}


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
  HelicsException* = object of ValueError

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
    m_helicsCreateCoreFromArgs: ProcWrapper[proc (`type`: cstring, name: cstring, argc: cint, argv: cstringArray, err: ptr HelicsError): HelicsCore {.cdecl.}]
    m_helicsCoreClone: ProcWrapper[proc (core: HelicsCore, err: ptr HelicsError): HelicsCore {.cdecl.}]
    m_helicsCoreIsValid: ProcWrapper[proc (core: HelicsCore): HelicsBool {.cdecl.}]
    m_helicsCreateBroker: ProcWrapper[proc (`type`: cstring, name: cstring, initString: cstring, err: ptr HelicsError): HelicsBroker {.cdecl.}]
    m_helicsCreateBrokerFromArgs: ProcWrapper[proc (`type`: cstring, name: cstring, argc: cint, argv: cstringArray, err: ptr HelicsError): HelicsBroker {.cdecl.}]
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
    m_helicsFederateInfoLoadFromArgs: ProcWrapper[proc (fi: HelicsFederateInfo, argc: cint, argv: cstringArray, err: ptr HelicsError) {.cdecl.}]
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
    m_helicsEndpointGetType: ProcWrapper[proc (endpoint: HelicsEndpoint): cstring {.cdecl.}]
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


# **************************************************
#  * Common Functions
#  **************************************************
# *
#  * Get a version string for HELICS.
#
proc helicsGetVersion(l: HelicsLibrary): string =
  loadSym("helicsGetVersion")
  result = $(f())

# *
#  * Get the build flags used to compile HELICS.
#
proc helicsGetBuildFlags*(l: HelicsLibrary): string =
  loadSym("helicsGetBuildFlags")
  result = $(f())

# *
#  * Get the compiler version used to compile HELICS.
#
proc helicsGetCompilerVersion*(l: HelicsLibrary): string =
  loadSym("helicsGetCompilerVersion")
  result = $(f())

# *
#  * Return an initialized error object.
#
proc helicsErrorInitialize*(l: HelicsLibrary): HelicsError =
  loadSym("helicsErrorInitialize")
  result = f()

# *
#  * Clear an error object.
#
proc helicsErrorClear*(l: HelicsLibrary, err: ptr HelicsError) =
  loadSym("helicsErrorClear")
  f(err)

# *
#  * Returns true if core/broker type specified is available in current compilation.
#  *
#  * @param type A string representing a core type.
#  *
#  * @details Options include "zmq", "udp", "ipc", "interprocess", "tcp", "default", "mpi".
#
proc helicsIsCoreTypeAvailable*(l: HelicsLibrary, `type`: string): HelicsBool =
  loadSym("helicsIsCoreTypeAvailable")
  result = f(`type`.cstring)

# *
#  * Create a core object.
#  *
#  * @param type The type of the core to create.
#  * @param name The name of the core. It can be a nullptr or empty string to have a name automatically assigned.
#  * @param initString An initialization string to send to the core. The format is similar to command line arguments.
#  *                   Typical options include a broker name, the broker address, the number of federates, etc.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return A helics_core object.
#  * @forcpponly
#  * If the core is invalid, err will contain the corresponding error message and the returned object will be NULL.
#  * @endforcpponly
#
proc helicsCreateCore*(l: HelicsLibrary, `type`: string, name: string, initString: string): HelicsCore =
  loadSym("helicsCreateCore")
  let err = l.helicsErrorInitialize()
  result = f(`type`.cstring, name.cstring, initString.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Create a core object by passing command line arguments.
#  *
#  * @param type The type of the core to create.
#  * @param name The name of the core. It can be a nullptr or empty string to have a name automatically assigned.
#  * @forcpponly
#  * @param argc The number of arguments.
#  * @endforcpponly
#  * @param argv The list of string values from a command line.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string
#  *                    if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return A helics_core object.
#
proc helicsCreateCoreFromArgs*(l: HelicsLibrary, `type`: string, name: string, arguments: seq[string]): HelicsCore =
  loadSym("helicsCreateCoreFromArgs")
  let argc = arguments.len
  var argv = allocCStringArray([])
  for i, s in arguments.pairs():
    argv[i] = s
  let err = l.helicsErrorInitialize()
  result = f(`type`, name.cstring, argc.cint, argv, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Create a new reference to an existing core.
#  *
#  * @details This will create a new broker object that references the existing broker. The new broker object must be freed as well.
#  *
#  * @param core An existing helics_core.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return A new reference to the same broker.
#
proc helicsCoreClone*(l: HelicsLibrary, core: HelicsCore): HelicsCore =
  loadSym("helicsCoreClone")
  let err = l.helicsErrorInitialize()
  result = f(core, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Check if a core object is a valid object.
#  *
#  * @param core The helics_core object to test.
#
proc helicsCoreIsValid*(l: HelicsLibrary, core: HelicsCore): HelicsBool =
  loadSym("helicsCoreIsValid")
  result = f(core)

# *
#  * Create a broker object.
#  *
#  * @param type The type of the broker to create.
#  * @param name The name of the broker. It can be a nullptr or empty string to have a name automatically assigned.
#  * @param initString An initialization string to send to the core-the format is similar to command line arguments.
#  *                   Typical options include a broker address such as --broker="XSSAF" if this is a subbroker, or the number of federates,
#  * or the address.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return A helics_broker object.
#  * @forcpponly
#  * It will be NULL if there was an error indicated in the err object.
#  * @endforcpponly
#
proc helicsCreateBroker*(l: HelicsLibrary, `type`: string, name: string, initString: string): HelicsBroker =
  loadSym("helicsCreateBroker")
  let err = l.helicsErrorInitialize()
  result = f(`type`, name.cstring, initString.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Create a core object by passing command line arguments.
#  *
#  * @param type The type of the core to create.
#  * @param name The name of the core. It can be a nullptr or empty string to have a name automatically assigned.
#  * @forcpponly
#  * @param argc The number of arguments.
#  * @endforcpponly
#  * @param argv The list of string values from a command line.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return A helics_core object.
#
proc helicsCreateBrokerFromArgs*(l: HelicsLibrary, `type`: string, name: string, arguments: seq[string]): HelicsBroker =
  loadSym("helicsCreateBrokerFromArgs")
  let argc = arguments.len
  var argv = allocCStringArray([])
  for i, s in arguments.pairs():
    argv[i] = s
  let err = l.helicsErrorInitialize()
  result = f(`type`, name.cstring, argc.cint, argv, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Create a new reference to an existing broker.
#  *
#  * @details This will create a new broker object that references the existing broker it must be freed as well.
#  *
#  * @param broker An existing helics_broker.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return A new reference to the same broker.
#
proc helicsBrokerClone*(l: HelicsLibrary, broker: HelicsBroker): HelicsBroker =
  loadSym("helicsBrokerClone")
  let err = l.helicsErrorInitialize()
  result = f(broker, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Check if a broker object is a valid object.
#  *
#  * @param broker The helics_broker object to test.
#
proc helicsBrokerIsValid*(l: HelicsLibrary, broker: HelicsBroker): HelicsBool =
  loadSym("helicsBrokerIsValid")
  result = f(broker)

# *
#  * Check if a broker is connected.
#  *
#  * @details A connected broker implies it is attached to cores or cores could reach out to communicate.
#  *
#  * @return helics_false if not connected.
#
proc helicsBrokerIsConnected*(l: HelicsLibrary, broker: HelicsBroker): HelicsBool =
  loadSym("helicsBrokerIsConnected")
  result = f(broker)

# *
#  * Link a named publication and named input using a broker.
#  *
#  * @param broker The broker to generate the connection from.
#  * @param source The name of the publication (cannot be NULL).
#  * @param target The name of the target to send the publication data (cannot be NULL).
#  * @forcpponly
#  * @param[in,out] err A helics_error object, can be NULL if the errors are to be ignored.
#  * @endforcpponly
#
proc helicsBrokerDataLink*(l: HelicsLibrary, broker: HelicsBroker, source: string, target: string) =
  loadSym("helicsBrokerDataLink")
  let err = l.helicsErrorInitialize()
  f(broker, source.cstring, target.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Link a named filter to a source endpoint.
#  *
#  * @param broker The broker to generate the connection from.
#  * @param filter The name of the filter (cannot be NULL).
#  * @param endpoint The name of the endpoint to filter the data from (cannot be NULL).
#  * @forcpponly
#  * @param[in,out] err A helics_error object, can be NULL if the errors are to be ignored.
#  * @endforcpponly
#
proc helicsBrokerAddSourceFilterToEndpoint*(l: HelicsLibrary, broker: HelicsBroker, filter: string, endpoint: string) =
  loadSym("helicsBrokerAddSourceFilterToEndpoint")
  let err = l.helicsErrorInitialize()
  f(broker, filter.cstring, endpoint.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Link a named filter to a destination endpoint.
#  *
#  * @param broker The broker to generate the connection from.
#  * @param filter The name of the filter (cannot be NULL).
#  * @param endpoint The name of the endpoint to filter the data going to (cannot be NULL).
#  * @forcpponly
#  * @param[in,out] err A helics_error object, can be NULL if the errors are to be ignored.
#  * @endforcpponly
#
proc helicsBrokerAddDestinationFilterToEndpoint*(l: HelicsLibrary, broker: HelicsBroker, filter: string, endpoint: string) =
  loadSym("helicsBrokerAddDestinationFilterToEndpoint")
  let err = l.helicsErrorInitialize()
  f(broker, filter.cstring, endpoint.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Load a file containing connection information.
#  *
#  * @param broker The broker to generate the connections from.
#  * @param file A JSON or TOML file containing connection information.
#  * @forcpponly
#  * @param[in,out] err A helics_error object, can be NULL if the errors are to be ignored.
#  * @endforcpponly
#
proc helicsBrokerMakeConnections*(l: HelicsLibrary, broker: HelicsBroker, file: string) =
  loadSym("helicsBrokerMakeConnections")
  let err = l.helicsErrorInitialize()
  f(broker, file.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Wait for the core to disconnect.
#  *
#  * @param core The core to wait for.
#  * @param msToWait The time out in millisecond (<0 for infinite timeout).
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return helics_true if the disconnect was successful, helics_false if there was a timeout.
#
proc helicsCoreWaitForDisconnect*(l: HelicsLibrary, core: HelicsCore, msToWait: int): HelicsBool =
  loadSym("helicsCoreWaitForDisconnect")
  let err = l.helicsErrorInitialize()
  result = f(core, msToWait.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Wait for the broker to disconnect.
#  *
#  * @param broker The broker to wait for.
#  * @param msToWait The time out in millisecond (<0 for infinite timeout).
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return helics_true if the disconnect was successful, helics_false if there was a timeout.
#
proc helicsBrokerWaitForDisconnect*(l: HelicsLibrary, broker: HelicsBroker, msToWait: int): HelicsBool =
  loadSym("helicsBrokerWaitForDisconnect")
  let err = l.helicsErrorInitialize()
  result = f(broker, msToWait.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Check if a core is connected.
#  *
#  * @details A connected core implies it is attached to federates or federates could be attached to it
#  *
#  * @return helics_false if not connected, helics_true if it is connected.
#
proc helicsCoreIsConnected*(l: HelicsLibrary, core: HelicsCore): HelicsBool =
  loadSym("helicsCoreIsConnected")
  result = f(core)

# *
#  * Link a named publication and named input using a core.
#  *
#  * @param core The core to generate the connection from.
#  * @param source The name of the publication (cannot be NULL).
#  * @param target The name of the target to send the publication data (cannot be NULL).
#  * @forcpponly
#  * @param[in,out] err A helics_error object, can be NULL if the errors are to be ignored.
#  * @endforcpponly
#
proc helicsCoreDataLink*(l: HelicsLibrary, core: HelicsCore, source: string, target: string) =
  loadSym("helicsCoreDataLink")
  let err = l.helicsErrorInitialize()
  f(core, source.cstring, target.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Link a named filter to a source endpoint.
#  *
#  * @param core The core to generate the connection from.
#  * @param filter The name of the filter (cannot be NULL).
#  * @param endpoint The name of the endpoint to filter the data from (cannot be NULL).
#  * @forcpponly
#  * @param[in,out] err A helics_error object, can be NULL if the errors are to be ignored.
#  * @endforcpponly
#
proc helicsCoreAddSourceFilterToEndpoint*(l: HelicsLibrary, core: HelicsCore, filter: string, endpoint: string) =
  loadSym("helicsCoreAddSourceFilterToEndpoint")
  let err = l.helicsErrorInitialize()
  f(core, filter.cstring, endpoint.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Link a named filter to a destination endpoint.
#  *
#  * @param core The core to generate the connection from.
#  * @param filter The name of the filter (cannot be NULL).
#  * @param endpoint The name of the endpoint to filter the data going to (cannot be NULL).
#  * @forcpponly
#  * @param[in,out] err A helics_error object, can be NULL if the errors are to be ignored.
#  * @endforcpponly
#
proc helicsCoreAddDestinationFilterToEndpoint*(l: HelicsLibrary, core: HelicsCore, filter: string, endpoint: string) =
  loadSym("helicsCoreAddDestinationFilterToEndpoint")
  let err = l.helicsErrorInitialize()
  f(core, filter.cstring, endpoint.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Load a file containing connection information.
#  *
#  * @param core The core to generate the connections from.
#  * @param file A JSON or TOML file containing connection information.
#  * @forcpponly
#  * @param[in,out] err A helics_error object, can be NULL if the errors are to be ignored.
#  * @endforcpponly
#
proc helicsCoreMakeConnections*(l: HelicsLibrary, core: HelicsCore, file: string) =
  loadSym("helicsCoreMakeConnections")
  let err = l.helicsErrorInitialize()
  f(core, file.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get an identifier for the broker.
#  *
#  * @param broker The broker to query.
#  *
#  * @return A string containing the identifier for the broker.
#
proc helicsBrokerGetIdentifier*(l: HelicsLibrary, broker: HelicsBroker): string =
  loadSym("helicsBrokerGetIdentifier")
  result = $(f(broker))

# *
#  * Get an identifier for the core.
#  *
#  * @param core The core to query.
#  *
#  * @return A string with the identifier of the core.
#
proc helicsCoreGetIdentifier*(l: HelicsLibrary, core: HelicsCore): string =
  loadSym("helicsCoreGetIdentifier")
  result = $(f(core))

# *
#  * Get the network address associated with a broker.
#  *
#  * @param broker The broker to query.
#  *
#  * @return A string with the network address of the broker.
#
proc helicsBrokerGetAddress*(l: HelicsLibrary, broker: HelicsBroker): string =
  loadSym("helicsBrokerGetAddress")
  result = $(f(broker))

# *
#  * Get the network address associated with a core.
#  *
#  * @param core The core to query.
#  *
#  * @return A string with the network address of the broker.
#
proc helicsCoreGetAddress*(l: HelicsLibrary, core: HelicsCore): string =
  loadSym("helicsCoreGetAddress")
  result = $(f(core))

# *
#  * Set the core to ready for init.
#  *
#  * @details This function is used for cores that have filters but no federates so there needs to be
#  *          a direct signal to the core to trigger the federation initialization.
#  *
#  * @param core The core object to enable init values for.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsCoreSetReadyToInit*(l: HelicsLibrary, core: HelicsCore) =
  loadSym("helicsCoreSetReadyToInit")
  let err = l.helicsErrorInitialize()
  f(core, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Connect a core to the federate based on current configuration.
#  *
#  * @param core The core to connect.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return helics_false if not connected, helics_true if it is connected.
#
proc helicsCoreConnect*(l: HelicsLibrary, core: HelicsCore): HelicsBool =
  loadSym("helicsCoreConnect")
  let err = l.helicsErrorInitialize()
  result = f(core, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Disconnect a core from the federation.
#  *
#  * @param core The core to query.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsCoreDisconnect*(l: HelicsLibrary, core: HelicsCore) =
  loadSym("helicsCoreDisconnect")
  let err = l.helicsErrorInitialize()
  f(core, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get an existing federate object from a core by name.
#  *
#  * @details The federate must have been created by one of the other functions and at least one of the objects referencing the created
#  *          federate must still be active in the process.
#  *
#  * @param fedName The name of the federate to retrieve.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return NULL if no fed is available by that name otherwise a helics_federate with that name.
#
proc helicsGetFederateByName*(l: HelicsLibrary, fedName: string): HelicsFederate =
  loadSym("helicsGetFederateByName")
  let err = l.helicsErrorInitialize()
  result = f(fedName.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Disconnect a broker.
#  *
#  * @param broker The broker to disconnect.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsBrokerDisconnect*(l: HelicsLibrary, broker: HelicsBroker) =
  loadSym("helicsBrokerDisconnect")
  let err = l.helicsErrorInitialize()
  f(broker, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Disconnect and free a federate.
#
proc helicsFederateDestroy*(l: HelicsLibrary, fed: HelicsFederate) =
  loadSym("helicsFederateDestroy")
  f(fed)

# *
#  * Disconnect and free a broker.
#
proc helicsBrokerDestroy*(l: HelicsLibrary, broker: HelicsBroker) =
  loadSym("helicsBrokerDestroy")
  f(broker)

# *
#  * Disconnect and free a core.
#
proc helicsCoreDestroy*(l: HelicsLibrary, core: HelicsCore) =
  loadSym("helicsCoreDestroy")
  f(core)

# *
#  * Release the memory associated with a core.
#
proc helicsCoreFree*(l: HelicsLibrary, core: HelicsCore) =
  loadSym("helicsCoreFree")
  f(core)

# *
#  * Release the memory associated with a broker.
#
proc helicsBrokerFree*(l: HelicsLibrary, broker: HelicsBroker) =
  loadSym("helicsBrokerFree")
  f(broker)

#
#  * Creation and destruction of Federates.
#
# *
#  * Create a value federate from a federate info object.
#  *
#  * @details helics_federate objects can be used in all functions that take a helics_federate or helics_federate object as an argument.
#  *
#  * @param fedName The name of the federate to create, can NULL or an empty string to use the default name from fi or an assigned name.
#  * @param fi The federate info object that contains details on the federate.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return An opaque value federate object.
#
proc helicsCreateValueFederate*(l: HelicsLibrary, fedName: string, fi: HelicsFederateInfo): HelicsFederate =
  loadSym("helicsCreateValueFederate")
  let err = l.helicsErrorInitialize()
  result = f(fedName.cstring, fi, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Create a value federate from a JSON file, JSON string, or TOML file.
#  *
#  * @details helics_federate objects can be used in all functions that take a helics_federate or helics_federate object as an argument.
#  *
#  * @param configFile A JSON file or a JSON string or TOML file that contains setup and configuration information.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return An opaque value federate object.
#
proc helicsCreateValueFederateFromConfig*(l: HelicsLibrary, configFile: string): HelicsFederate =
  loadSym("helicsCreateValueFederateFromConfig")
  let err = l.helicsErrorInitialize()
  result = f(configFile.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Create a message federate from a federate info object.
#  *
#  * @details helics_message_federate objects can be used in all functions that take a helics_message_federate or helics_federate object as an
#  * argument.
#  *
#  * @param fedName The name of the federate to create.
#  * @param fi The federate info object that contains details on the federate.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return An opaque message federate object.
#
proc helicsCreateMessageFederate*(l: HelicsLibrary, fedName: string, fi: HelicsFederateInfo): HelicsFederate =
  loadSym("helicsCreateMessageFederate")
  let err = l.helicsErrorInitialize()
  result = f(fedName, fi, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Create a message federate from a JSON file or JSON string or TOML file.
#  *
#  * @details helics_message_federate objects can be used in all functions that take a helics_message_federate or helics_federate object as an
#  * argument.
#  *
#  * @param configFile A Config(JSON,TOML) file or a JSON string that contains setup and configuration information.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return An opaque message federate object.
#
proc helicsCreateMessageFederateFromConfig*(l: HelicsLibrary, configFile: string): HelicsFederate =
  loadSym("helicsCreateMessageFederateFromConfig")
  let err = l.helicsErrorInitialize()
  result = f(configFile.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Create a combination federate from a federate info object.
#  *
#  * @details Combination federates are both value federates and message federates, objects can be used in all functions
#  *                      that take a helics_federate, helics_message_federate or helics_federate object as an argument
#  *
#  * @param fedName A string with the name of the federate, can be NULL or an empty string to pull the default name from fi.
#  * @param fi The federate info object that contains details on the federate.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return An opaque value federate object nullptr if the object creation failed.
#
proc helicsCreateCombinationFederate*(l: HelicsLibrary, fedName: string, fi: HelicsFederateInfo): HelicsFederate =
  loadSym("helicsCreateCombinationFederate")
  let err = l.helicsErrorInitialize()
  result = f(fedName.cstring, fi, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Create a combination federate from a JSON file or JSON string or TOML file.
#  *
#  * @details Combination federates are both value federates and message federates, objects can be used in all functions
#  *          that take a helics_federate, helics_message_federate or helics_federate object as an argument
#  *
#  * @param configFile A JSON file or a JSON string or TOML file that contains setup and configuration information.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return An opaque combination federate object.
#
proc helicsCreateCombinationFederateFromConfig*(l: HelicsLibrary, configFile: string): HelicsFederate =
  loadSym("helicsCreateCombinationFederateFromConfig")
  let err = l.helicsErrorInitialize()
  result = f(configFile.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Create a new reference to an existing federate.
#  *
#  * @details This will create a new helics_federate object that references the existing federate. The new object must be freed as well.
#  *
#  * @param fed An existing helics_federate.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return A new reference to the same federate.
#
proc helicsFederateClone*(l: HelicsLibrary, fed: HelicsFederate): HelicsFederate =
  loadSym("helicsFederateClone")
  let err = l.helicsErrorInitialize()
  result = f(fed, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Create a federate info object for specifying federate information when constructing a federate.
#  *
#  * @return A helics_federate_info object which is a reference to the created object.
#
proc helicsCreateFederateInfo*(l: HelicsLibrary): HelicsFederateInfo =
  loadSym("helicsCreateFederateInfo")
  result = f()

# *
#  * Create a federate info object from an existing one and clone the information.
#  *
#  * @param fi A federateInfo object to duplicate.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  *  @return A helics_federate_info object which is a reference to the created object.
#
proc helicsFederateInfoClone*(l: HelicsLibrary, fi: HelicsFederateInfo): HelicsFederateInfo =
  loadSym("helicsFederateInfoClone")
  let err = l.helicsErrorInitialize()
  result = f(fi, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Load federate info from command line arguments.
#  *
#  * @param fi A federateInfo object.
#  * @param argc The number of command line arguments.
#  * @param argv An array of strings from the command line.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateInfoLoadFromArgs*(l: HelicsLibrary, fi: HelicsFederateInfo, arguments: seq[string]) =
  loadSym("helicsFederateInfoLoadFromArgs")
  let err = l.helicsErrorInitialize()
  let argc = arguments.len
  var argv = allocCStringArray([])
  for i, s in arguments.pairs():
    argv[i] = s
  f(fi, argc.cint, argv, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Delete the memory associated with a federate info object.
#
proc helicsFederateInfoFree*(l: HelicsLibrary, fi: HelicsFederateInfo) =
  loadSym("helicsFederateInfoFree")
  f(fi)

# *
#  * Check if a federate_object is valid.
#  *
#  * @return helics_true if the federate is a valid active federate, helics_false otherwise
#
proc helicsFederateIsValid*(l: HelicsLibrary, fed: HelicsFederate): HelicsBool =
  loadSym("helicsFederateIsValid")
  result = f(fed)

# *
#  * Set the name of the core to link to for a federate.
#  *
#  * @param fi The federate info object to alter.
#  * @param corename The identifier for a core to link to.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateInfoSetCoreName*(l: HelicsLibrary, fi: HelicsFederateInfo, corename: string) =
  loadSym("helicsFederateInfoSetCoreName")
  let err = l.helicsErrorInitialize()
  f(fi, corename.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the initialization string for the core usually in the form of command line arguments.
#  *
#  * @param fi The federate info object to alter.
#  * @param coreInit A string containing command line arguments to be passed to the core.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateInfoSetCoreInitString*(l: HelicsLibrary, fi: HelicsFederateInfo, coreInit: string) =
  loadSym("helicsFederateInfoSetCoreInitString")
  let err = l.helicsErrorInitialize()
  f(fi, coreInit.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the initialization string that a core will pass to a generated broker usually in the form of command line arguments.
#  *
#  * @param fi The federate info object to alter.
#  * @param brokerInit A string with command line arguments for a generated broker.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateInfoSetBrokerInitString*(l: HelicsLibrary, fi: HelicsFederateInfo, brokerInit: string) =
  loadSym("helicsFederateInfoSetBrokerInitString")
  let err = l.helicsErrorInitialize()
  f(fi, brokerInit.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the core type by integer code.
#  *
#  * @details Valid values available by definitions in api-data.h.
#  * @param fi The federate info object to alter.
#  * @param coretype An numerical code for a core type see /ref helics_core_type.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateInfoSetCoreType*(l: HelicsLibrary, fi: HelicsFederateInfo, coretype: int) =
  loadSym("helicsFederateInfoSetCoreType")
  let err = l.helicsErrorInitialize()
  f(fi, coretype.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the core type from a string.
#  *
#  * @param fi The federate info object to alter.
#  * @param coretype A string naming a core type.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateInfoSetCoreTypeFromString*(l: HelicsLibrary, fi: HelicsFederateInfo, coretype: string) =
  loadSym("helicsFederateInfoSetCoreTypeFromString")
  let err = l.helicsErrorInitialize()
  f(fi, coretype.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the name or connection information for a broker.
#  *
#  * @details This is only used if the core is automatically created, the broker information will be transferred to the core for connection.
#  * @param fi The federate info object to alter.
#  * @param broker A string which defines the connection information for a broker either a name or an address.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateInfoSetBroker*(l: HelicsLibrary, fi: HelicsFederateInfo, broker: string) =
  loadSym("helicsFederateInfoSetBroker")
  let err = l.helicsErrorInitialize()
  f(fi, broker.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the key for a broker connection.
#  *
#  * @details This is only used if the core is automatically created, the broker information will be transferred to the core for connection.
#  * @param fi The federate info object to alter.
#  * @param brokerkey A string containing a key for the broker to connect.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateInfoSetBrokerKey*(l: HelicsLibrary, fi: HelicsFederateInfo, brokerkey: string) =
  loadSym("helicsFederateInfoSetBrokerKey")
  let err = l.helicsErrorInitialize()
  f(fi, brokerkey.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the port to use for the broker.
#  *
#  * @details This is only used if the core is automatically created, the broker information will be transferred to the core for connection.
#  * This will only be useful for network broker connections.
#  * @param fi The federate info object to alter.
#  * @param brokerPort The integer port number to use for connection with a broker.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateInfoSetBrokerPort*(l: HelicsLibrary, fi: HelicsFederateInfo, brokerPort: int) =
  loadSym("helicsFederateInfoSetBrokerPort")
  let err = l.helicsErrorInitialize()
  f(fi, brokerPort.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the local port to use.
#  *
#  * @details This is only used if the core is automatically created, the port information will be transferred to the core for connection.
#  * @param fi The federate info object to alter.
#  * @param localPort A string with the port information to use as the local server port can be a number or "auto" or "os_local".
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateInfoSetLocalPort*(l: HelicsLibrary, fi: HelicsFederateInfo, localPort: string) =
  loadSym("helicsFederateInfoSetLocalPort")
  let err = l.helicsErrorInitialize()
  f(fi, localPort.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get a property index for use in /ref helicsFederateInfoSetFlagOption, /ref helicsFederateInfoSetTimeProperty,
#  * or /ref helicsFederateInfoSetIntegerProperty
#  * @param val A string with the property name.
#  * @return An int with the property code or (-1) if not a valid property.
#
proc helicsGetPropertyIndex*(l: HelicsLibrary, val: string): int =
  loadSym("helicsGetPropertyIndex")
  f(val.cstring)

# *
#  * Get a property index for use in /ref helicsFederateInfoSetFlagOption, /ref helicsFederateSetFlagOption,
#  * @param val A string with the option name.
#  * @return An int with the property code or (-1) if not a valid property.
#
proc helicsGetFlagIndex*(l: HelicsLibrary, val: string): int =
  loadSym("helicsGetFlagIndex")
  f(val.cstring)

# *
#  * Get an option index for use in /ref helicsPublicationSetOption, /ref helicsInputSetOption, /ref helicsEndpointSetOption,
#  * /ref helicsFilterSetOption, and the corresponding get functions.
#  *
#  * @param val A string with the option name.
#  *
#  * @return An int with the option index or (-1) if not a valid property.
#
proc helicsGetOptionIndex*(l: HelicsLibrary, val: string): int =
  loadSym("helicsGetOptionIndex")
  f(val.cstring)

# *
#  * Get an option value for use in /ref helicsPublicationSetOption, /ref helicsInputSetOption, /ref helicsEndpointSetOption,
#  * /ref helicsFilterSetOption.
#  *
#  * @param val A string representing the value.
#  *
#  * @return An int with the option value or (-1) if not a valid value.
#
proc helicsGetOptionValue*(l: HelicsLibrary, val: string): int =
  loadSym("helicsGetOptionValue")
  f(val.cstring)

# *
#  * Set a flag in the info structure.
#  *
#  * @details Valid flags are available /ref helics_federate_flags.
#  * @param fi The federate info object to alter.
#  * @param flag A numerical index for a flag.
#  * @param value The desired value of the flag helics_true or helics_false.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateInfoSetFlagOption*(l: HelicsLibrary, fi: HelicsFederateInfo, flag: int, value: HelicsBool) =
  loadSym("helicsFederateInfoSetFlagOption")
  let err = l.helicsErrorInitialize()
  f(fi, flag.cint, value, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the separator character in the info structure.
#  *
#  * @details The separator character is the separation character for local publications/endpoints in creating their global name.
#  * For example if the separator character is '/'  then a local endpoint would have a globally reachable name of fedName/localName.
#  * @param fi The federate info object to alter.
#  * @param separator The character to use as a separator.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateInfoSetSeparator*(l: HelicsLibrary, fi: HelicsFederateInfo, separator: char) =
  loadSym("helicsFederateInfoSetSeparator")
  let err = l.helicsErrorInitialize()
  f(fi, separator.cchar, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))


# *
#  * Set the output delay for a federate.
#  *
#  * @param fi The federate info object to alter.
#  * @param timeProperty An integer representation of the time based property to set see /ref helics_properties.
#  * @param propertyValue The value of the property to set the timeProperty to.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateInfoSetTimeProperty*(l: HelicsLibrary, fi: HelicsFederateInfo, timeProperty: int, propertyValue: HelicsTime) =
  loadSym("helicsFederateInfoSetTimeProperty")
  let err = l.helicsErrorInitialize()
  f(fi, timeProperty.cint, propertyValue, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set an integer property for a federate.
#  *
#  * @details Set known properties.
#  *
#  * @param fi The federateInfo object to alter.
#  * @param intProperty An int identifying the property.
#  * @param propertyValue The value to set the property to.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateInfoSetIntegerProperty*(l: HelicsLibrary, fi: HelicsFederateInfo, intProperty: int, propertyValue: int) =
  loadSym("helicsFederateInfoSetIntegerProperty")
  let err = l.helicsErrorInitialize()
  f(fi, intProperty.cint, propertyValue.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Load interfaces from a file.
#  *
#  * @param fed The federate to which to load interfaces.
#  * @param file The name of a file to load the interfaces from either JSON, or TOML.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateRegisterInterfaces*(l: HelicsLibrary, fed: HelicsFederate, file: string) =
  loadSym("helicsFederateRegisterInterfaces")
  let err = l.helicsErrorInitialize()
  f(fed, file.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Generate a global error from a federate.
#  *
#  * @details A global error halts the co-simulation completely.
#  *
#  * @param fed The federate to create an error in.
#  * @param error_code The integer code for the error.
#  * @param error_string A string describing the error.
#
proc helicsFederateGlobalError*(l: HelicsLibrary, fed: HelicsFederate, error_code: int, error_string: string) =
  loadSym("helicsFederateGlobalError")
  f(fed, error_code.cint, error_string.cstring)

# *
#  * Generate a local error in a federate.
#  *
#  * @details This will propagate through the co-simulation but not necessarily halt the co-simulation, it has a similar effect to finalize
#  * but does allow some interaction with a core for a brief time.
#  * @param fed The federate to create an error in.
#  * @param error_code The integer code for the error.
#  * @param error_string A string describing the error.
#
proc helicsFederateLocalError*(l: HelicsLibrary, fed: HelicsFederate, error_code: int, error_string: string) =
  loadSym("helicsFederateLocalError")
  f(fed, error_code.cint, error_string.cstring)

# *
#  * Finalize the federate. This function halts all communication in the federate and disconnects it from the core.
#
proc helicsFederateFinalize*(l: HelicsLibrary, fed: HelicsFederate) =
  loadSym("helicsFederateFinalize")
  let err = l.helicsErrorInitialize()
  f(fed, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Finalize the federate in an async call.
#
proc helicsFederateFinalizeAsync*(l: HelicsLibrary, fed: HelicsFederate) =
  loadSym("helicsFederateFinalizeAsync")
  let err = l.helicsErrorInitialize()
  f(fed, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Complete the asynchronous finalize call.
#
proc helicsFederateFinalizeComplete*(l: HelicsLibrary, fed: HelicsFederate) =
  loadSym("helicsFederateFinalizeComplete")
  let err = l.helicsErrorInitialize()
  f(fed, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Release the memory associated with a federate.
#
proc helicsFederateFree*(l: HelicsLibrary, fed: HelicsFederate) =
  loadSym("helicsFederateFree")
  f(fed)

# *
#  * Call when done using the helics library.
#  * This function will ensure the threads are closed properly. If possible this should be the last call before exiting.
#
proc helicsCloseLibrary*(l: HelicsLibrary) =
  loadSym("helicsCloseLibrary")
  f()

#
#  * Initialization, execution, and time requests.
#
# *
#  * Enter the initialization state of a federate.
#  *
#  * @details The initialization state allows initial values to be set and received if the iteration is requested on entry to the execution
#  * state. This is a blocking call and will block until the core allows it to proceed.
#  *
#  * @param fed The federate to operate on.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateEnterInitializingMode*(l: HelicsLibrary, fed: HelicsFederate) =
  loadSym("helicsFederateEnterInitializingMode")
  let err = l.helicsErrorInitialize()
  f(fed, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Non blocking alternative to \ref helicsFederateEnterInitializingMode.
#  *
#  * @details The function helicsFederateEnterInitializationModeFinalize must be called to finish the operation.
#  *
#  * @param fed The federate to operate on.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateEnterInitializingModeAsync*(l: HelicsLibrary, fed: HelicsFederate) =
  loadSym("helicsFederateEnterInitializingModeAsync")
  let err = l.helicsErrorInitialize()
  f(fed, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Check if the current Asynchronous operation has completed.
#  *
#  * @param fed The federate to operate on.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return helics_false if not completed, helics_true if completed.
#
proc helicsFederateIsAsyncOperationCompleted*(l: HelicsLibrary, fed: HelicsFederate): HelicsBool =
  loadSym("helicsFederateIsAsyncOperationCompleted")
  let err = l.helicsErrorInitialize()
  result = f(fed, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Finalize the entry to initialize mode that was initiated with /ref heliceEnterInitializingModeAsync.
#  *
#  * @param fed The federate desiring to complete the initialization step.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateEnterInitializingModeComplete*(l: HelicsLibrary, fed: HelicsFederate) =
  loadSym("helicsFederateEnterInitializingModeComplete")
  let err = l.helicsErrorInitialize()
  f(fed, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Request that the federate enter the Execution mode.
#  *
#  * @details This call is blocking until granted entry by the core object. On return from this call the federate will be at time 0.
#  *          For an asynchronous alternative call see /ref helicsFederateEnterExecutingModeAsync.
#  *
#  * @param fed A federate to change modes.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateEnterExecutingMode*(l: HelicsLibrary, fed: HelicsFederate) =
  loadSym("helicsFederateEnterExecutingMode")
  let err = l.helicsErrorInitialize()
  f(fed, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Request that the federate enter the Execution mode.
#  *
#  * @details This call is non-blocking and will return immediately. Call /ref helicsFederateEnterExecutingModeComplete to finish the call
#  * sequence.
#  *
#  * @param fed The federate object to complete the call.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateEnterExecutingModeAsync*(l: HelicsLibrary, fed: HelicsFederate) =
  loadSym("helicsFederateEnterExecutingModeAsync")
  let err = l.helicsErrorInitialize()
  f(fed, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Complete the call to /ref helicsFederateEnterExecutingModeAsync.
#  *
#  * @param fed The federate object to complete the call.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateEnterExecutingModeComplete*(l: HelicsLibrary, fed: HelicsFederate) =
  loadSym("helicsFederateEnterExecutingModeComplete")
  let err = l.helicsErrorInitialize()
  f(fed, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Request an iterative time.
#  *
#  * @details This call allows for finer grain control of the iterative process than /ref helicsFederateRequestTime. It takes a time and
#  *          iteration request, and returns a time and iteration status.
#  *
#  * @param fed The federate to make the request of.
#  * @param iterate The requested iteration mode.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return An iteration structure with field containing the time and iteration status.
#
proc helicsFederateEnterExecutingModeIterative*(l: HelicsLibrary, fed: HelicsFederate, iterate: HelicsIterationRequest): HelicsIterationResult =
  loadSym("helicsFederateEnterExecutingModeIterative")
  let err = l.helicsErrorInitialize()
  result = f(fed, iterate, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Request an iterative entry to the execution mode.
#  *
#  * @details This call allows for finer grain control of the iterative process than /ref helicsFederateRequestTime. It takes a time and
#  *          iteration request, and returns a time and iteration status
#  *
#  * @param fed The federate to make the request of.
#  * @param iterate The requested iteration mode.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateEnterExecutingModeIterativeAsync*(l: HelicsLibrary, fed: HelicsFederate, iterate: HelicsIterationRequest) =
  loadSym("helicsFederateEnterExecutingModeIterativeAsync")
  let err = l.helicsErrorInitialize()
  f(fed, iterate, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Complete the asynchronous iterative call into ExecutionMode.
#  *
#  * @param fed The federate to make the request of.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return An iteration object containing the iteration time and iteration_status.
#
proc helicsFederateEnterExecutingModeIterativeComplete*(l: HelicsLibrary, fed: HelicsFederate): HelicsIterationResult =
  loadSym("helicsFederateEnterExecutingModeIterativeComplete")
  let err = l.helicsErrorInitialize()
  result = f(fed, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get the current state of a federate.
#  *
#  * @param fed The federate to query.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return State the resulting state if void return helics_ok.
#
proc helicsFederateGetState*(l: HelicsLibrary, fed: HelicsFederate): HelicsFederateState =
  loadSym("helicsFederateGetState")
  let err = l.helicsErrorInitialize()
  result = f(fed, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get the core object associated with a federate.
#  *
#  * @param fed A federate object.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return A core object, nullptr if invalid.
#
proc helicsFederateGetCoreObject*(l: HelicsLibrary, fed: HelicsFederate): HelicsCore =
  loadSym("helicsFederateGetCoreObject")
  let err = l.helicsErrorInitialize()
  result = f(fed, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Request the next time for federate execution.
#  *
#  * @param fed The federate to make the request of.
#  * @param requestTime The next requested time.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return The time granted to the federate, will return helics_time_maxtime if the simulation has terminated or is invalid.
#
proc helicsFederateRequestTime*(l: HelicsLibrary, fed: HelicsFederate, requestTime: HelicsTime): HelicsTime =
  loadSym("helicsFederateRequestTime")
  let err = l.helicsErrorInitialize()
  result = f(fed, requestTime, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Request the next time for federate execution.
#  *
#  * @param fed The federate to make the request of.
#  * @param timeDelta The requested amount of time to advance.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return The time granted to the federate, will return helics_time_maxtime if the simulation has terminated or is invalid
#
proc helicsFederateRequestTimeAdvance*(l: HelicsLibrary, fed: HelicsFederate, timeDelta: HelicsTime): HelicsTime =
  loadSym("helicsFederateRequestTimeAdvance")
  let err = l.helicsErrorInitialize()
  result = f(fed, timeDelta, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Request the next time step for federate execution.
#  *
#  * @details Feds should have setup the period or minDelta for this to work well but it will request the next time step which is the current
#  * time plus the minimum time step.
#  *
#  * @param fed The federate to make the request of.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return The time granted to the federate, will return helics_time_maxtime if the simulation has terminated or is invalid
#
proc helicsFederateRequestNextStep*(l: HelicsLibrary, fed: HelicsFederate): HelicsTime =
  loadSym("helicsFederateRequestNextStep")
  let err = l.helicsErrorInitialize()
  result = f(fed, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Request an iterative time.
#  *
#  * @details This call allows for finer grain control of the iterative process than /ref helicsFederateRequestTime. It takes a time and
#  * iteration request, and returns a time and iteration status.
#  *
#  * @param fed The federate to make the request of.
#  * @param requestTime The next desired time.
#  * @param iterate The requested iteration mode.
#  * @forcpponly
#  * @param[out] outIteration  The iteration specification of the result.
#  * @endforcpponly
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return The granted time, will return helics_time_maxtime if the simulation has terminated along with the appropriate iteration result.
#  * @beginPythonOnly
#  * This function also returns the iteration specification of the result.
#  * @endPythonOnly
#
proc helicsFederateRequestTimeIterative*(l: HelicsLibrary, fed: HelicsFederate, requestTime: HelicsTime, iterate: HelicsIterationRequest, outIteration: ptr HelicsIterationResult): HelicsTime =
  loadSym("helicsFederateRequestTimeIterative")
  let err = l.helicsErrorInitialize()
  result = f(fed, requestTime, iterate, outIteration, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Request the next time for federate execution in an asynchronous call.
#  *
#  * @details Call /ref helicsFederateRequestTimeComplete to finish the call.
#  *
#  * @param fed The federate to make the request of.
#  * @param requestTime The next requested time.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateRequestTimeAsync*(l: HelicsLibrary, fed: HelicsFederate, requestTime: HelicsTime) =
  loadSym("helicsFederateRequestTimeAsync")
  let err = l.helicsErrorInitialize()
  f(fed, requestTime, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Complete an asynchronous requestTime call.
#  *
#  * @param fed The federate to make the request of.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return The time granted to the federate, will return helics_time_maxtime if the simulation has terminated.
#
proc helicsFederateRequestTimeComplete*(l: HelicsLibrary, fed: HelicsFederate): HelicsTime =
  loadSym("helicsFederateRequestTimeComplete")
  let err = l.helicsErrorInitialize()
  result = f(fed, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Request an iterative time through an asynchronous call.
#  *
#  * @details This call allows for finer grain control of the iterative process than /ref helicsFederateRequestTime. It takes a time and
#  * iteration request, and returns a time and iteration status. Call /ref helicsFederateRequestTimeIterativeComplete to finish the process.
#  *
#  * @param fed The federate to make the request of.
#  * @param requestTime The next desired time.
#  * @param iterate The requested iteration mode.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateRequestTimeIterativeAsync*(l: HelicsLibrary, fed: HelicsFederate, requestTime: HelicsTime, iterate: HelicsIterationRequest) =
  loadSym("helicsFederateRequestTimeIterativeAsync")
  let err = l.helicsErrorInitialize()
  f(fed, requestTime, iterate, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Complete an iterative time request asynchronous call.
#  *
#  * @param fed The federate to make the request of.
#  * @forcpponly
#  * @param[out] outIterate The iteration specification of the result.
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return The granted time, will return helics_time_maxtime if the simulation has terminated.
#  * @beginPythonOnly
#  * This function also returns the iteration specification of the result.
#  * @endPythonOnly
#
proc helicsFederateRequestTimeIterativeComplete*(l: HelicsLibrary, fed: HelicsFederate, outIterate: ptr HelicsIterationResult): HelicsTime =
  loadSym("helicsFederateRequestTimeIterativeComplete")
  let err = l.helicsErrorInitialize()
  result = f(fed, outIterate, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get the name of the federate.
#  *
#  * @param fed The federate object to query.
#  *
#  * @return A pointer to a string with the name.
#
proc helicsFederateGetName*(l: HelicsLibrary, fed: HelicsFederate): string =
  loadSym("helicsFederateGetName")
  result = $(f(fed))

# *
#  * Set a time based property for a federate.
#  *
#  * @param fed The federate object to set the property for.
#  * @param timeProperty A integer code for a time property.
#  * @param time The requested value of the property.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateSetTimeProperty*(l: HelicsLibrary, fed: HelicsFederate, timeProperty: int, time: HelicsTime) =
  loadSym("helicsFederateSetTimeProperty")
  let err = l.helicsErrorInitialize()
  f(fed, timeProperty.cint, time, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set a flag for the federate.
#  *
#  * @param fed The federate to alter a flag for.
#  * @param flag The flag to change.
#  * @param flagValue The new value of the flag. 0 for false, !=0 for true.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateSetFlagOption*(l: HelicsLibrary, fed: HelicsFederate, flag: int, flagValue: HelicsBool) =
  loadSym("helicsFederateSetFlagOption")
  let err = l.helicsErrorInitialize()
  f(fed, flag.cint, flagValue, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the separator character in a federate.
#  *
#  * @details The separator character is the separation character for local publications/endpoints in creating their global name.
#  *          For example if the separator character is '/' then a local endpoint would have a globally reachable name of fedName/localName.
#  *
#  * @param fed The federate info object to alter.
#  * @param separator The character to use as a separator.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateSetSeparator*(l: HelicsLibrary, fed: HelicsFederate, separator: char) =
  loadSym("helicsFederateSetSeparator")
  let err = l.helicsErrorInitialize()
  f(fed, separator.cchar, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set an integer based property of a federate.
#  *
#  * @param fed The federate to change the property for.
#  * @param intProperty The property to set.
#  * @param propertyVal The value of the property.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateSetIntegerProperty*(l: HelicsLibrary, fed: HelicsFederate, intProperty: int, propertyVal: int) =
  loadSym("helicsFederateSetIntegerProperty")
  let err = l.helicsErrorInitialize()
  f(fed, intProperty.cint, propertyVal.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get the current value of a time based property in a federate.
#  *
#  * @param fed The federate query.
#  * @param timeProperty The property to query.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsFederateGetTimeProperty*(l: HelicsLibrary, fed: HelicsFederate, timeProperty: int): HelicsTime =
  loadSym("helicsFederateGetTimeProperty")
  let err = l.helicsErrorInitialize()
  result = f(fed, timeProperty.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get a flag value for a federate.
#  *
#  * @param fed The federate to get the flag for.
#  * @param flag The flag to query.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return The value of the flag.
#
proc helicsFederateGetFlagOption*(l: HelicsLibrary, fed: HelicsFederate, flag: int): HelicsBool =
  loadSym("helicsFederateGetFlagOption")
  let err = l.helicsErrorInitialize()
  result = f(fed, flag.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get the current value of an integer property (such as a logging level).
#  *
#  * @param fed The federate to get the flag for.
#  * @param intProperty A code for the property to set /ref helics_handle_options.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return The value of the property.
#
proc helicsFederateGetIntegerProperty*(l: HelicsLibrary, fed: HelicsFederate, intProperty: int): int =
  loadSym("helicsFederateGetIntegerProperty")
  let err = l.helicsErrorInitialize()
  result = f(fed, intProperty.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get the current time of the federate.
#  *
#  * @param fed The federate object to query.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return The current time of the federate.
#
proc helicsFederateGetCurrentTime*(l: HelicsLibrary, fed: HelicsFederate): HelicsTime =
  loadSym("helicsFederateGetCurrentTime")
  let err = l.helicsErrorInitialize()
  result = f(fed, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set a federation global value through a federate.
#  *
#  * @details This overwrites any previous value for this name.
#  * @param fed The federate to set the global through.
#  * @param valueName The name of the global to set.
#  * @param value The value of the global.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsFederateSetGlobal*(l: HelicsLibrary, fed: HelicsFederate, valueName: string, value: string) =
  loadSym("helicsFederateSetGlobal")
  let err = l.helicsErrorInitialize()
  f(fed, valueName.cstring, value.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Add a time dependency for a federate. The federate will depend on the given named federate for time synchronization.
#  *
#  * @param fed The federate to add the dependency for.
#  * @param fedName The name of the federate to depend on.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsFederateAddDependency*(l: HelicsLibrary, fed: HelicsFederate, fedName: string) =
  loadSym("helicsFederateAddDependency")
  let err = l.helicsErrorInitialize()
  f(fed, fedName.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the logging file for a federate (actually on the core associated with a federate).
#  *
#  * @param fed The federate to set the log file for.
#  * @param logFile The name of the log file.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsFederateSetLogFile*(l: HelicsLibrary, fed: HelicsFederate, logFile: string) =
  loadSym("helicsFederateSetLogFile")
  let err = l.helicsErrorInitialize()
  f(fed, logFile.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Log an error message through a federate.
#  *
#  * @param fed The federate to log the error message through.
#  * @param logmessage The message to put in the log.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsFederateLogErrorMessage*(l: HelicsLibrary, fed: HelicsFederate, logmessage: string) =
  loadSym("helicsFederateLogErrorMessage")
  let err = l.helicsErrorInitialize()
  f(fed, logmessage.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Log a warning message through a federate.
#  *
#  * @param fed The federate to log the warning message through.
#  * @param logmessage The message to put in the log.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsFederateLogWarningMessage*(l: HelicsLibrary, fed: HelicsFederate, logmessage: string) =
  loadSym("helicsFederateLogWarningMessage")
  let err = l.helicsErrorInitialize()
  f(fed, logmessage.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Log an info message through a federate.
#  *
#  * @param fed The federate to log the info message through.
#  * @param logmessage The message to put in the log.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsFederateLogInfoMessage*(l: HelicsLibrary, fed: HelicsFederate, logmessage: string) =
  loadSym("helicsFederateLogInfoMessage")
  let err = l.helicsErrorInitialize()
  f(fed, logmessage.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Log a debug message through a federate.
#  *
#  * @param fed The federate to log the debug message through.
#  * @param logmessage The message to put in the log.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsFederateLogDebugMessage*(l: HelicsLibrary, fed: HelicsFederate, logmessage: string) =
  loadSym("helicsFederateLogDebugMessage")
  let err = l.helicsErrorInitialize()
  f(fed, logmessage.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Log a message through a federate.
#  *
#  * @param fed The federate to log the message through.
#  * @param loglevel The level of the message to log see /ref helics_log_levels.
#  * @param logmessage The message to put in the log.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsFederateLogLevelMessage*(l: HelicsLibrary, fed: HelicsFederate, loglevel: int, logmessage: string) =
  loadSym("helicsFederateLogLevelMessage")
  let err = l.helicsErrorInitialize()
  f(fed, loglevel.cint, logmessage.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set a global value in a core.
#  *
#  * @details This overwrites any previous value for this name.
#  *
#  * @param core The core to set the global through.
#  * @param valueName The name of the global to set.
#  * @param value The value of the global.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsCoreSetGlobal*(l: HelicsLibrary, core: HelicsCore, valueName: string, value: string) =
  loadSym("helicsCoreSetGlobal")
  let err = l.helicsErrorInitialize()
  f(core, valueName.cstring, value.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set a federation global value.
#  *
#  * @details This overwrites any previous value for this name.
#  *
#  * @param broker The broker to set the global through.
#  * @param valueName The name of the global to set.
#  * @param value The value of the global.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsBrokerSetGlobal*(l: HelicsLibrary, broker: HelicsBroker, valueName: string, value: string) =
  loadSym("helicsBrokerSetGlobal")
  let err = l.helicsErrorInitialize()
  f(broker, valueName.cstring, value.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the log file on a core.
#  *
#  * @param core The core to set the log file for.
#  * @param logFileName The name of the file to log to.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsCoreSetLogFile*(l: HelicsLibrary, core: HelicsCore, logFileName: string) =
  loadSym("helicsCoreSetLogFile")
  let err = l.helicsErrorInitialize()
  f(core, logFileName.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the log file on a broker.
#  *
#  * @param broker The broker to set the log file for.
#  * @param logFileName The name of the file to log to.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsBrokerSetLogFile*(l: HelicsLibrary, broker: HelicsBroker, logFileName: string) =
  loadSym("helicsBrokerSetLogFile")
  let err = l.helicsErrorInitialize()
  f(broker, logFileName.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Create a query object.
#  *
#  * @details A query object consists of a target and query string.
#  *
#  * @param target The name of the target to query.
#  * @param query The query to make of the target.
#
proc helicsCreateQuery*(l: HelicsLibrary, target: string, query: string): HelicsQuery =
  loadSym("helicsCreateQuery")
  f(target.cstring, query.cstring)

# *
#  * Execute a query.
#  *
#  * @details The call will block until the query finishes which may require communication or other delays.
#  *
#  * @param query The query object to use in the query.
#  * @param fed A federate to send the query through.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return A pointer to a string.  The string will remain valid until the query is freed or executed again.
#  * @forcpponly
#  *         The return will be nullptr if fed or query is an invalid object, the return string will be "#invalid" if the query itself was
#  * invalid.
#  * @endforcpponly
#
proc helicsQueryExecute*(l: HelicsLibrary, query: HelicsQuery, fed: HelicsFederate): string =
  loadSym("helicsQueryExecute")
  let err = l.helicsErrorInitialize()
  result = $(f(query, fed, unsafeAddr err))
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Execute a query directly on a core.
#  *
#  * @details The call will block until the query finishes which may require communication or other delays.
#  *
#  * @param query The query object to use in the query.
#  * @param core The core to send the query to.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return A pointer to a string.  The string will remain valid until the query is freed or executed again.
#  * @forcpponly
#  *         The return will be nullptr if core or query is an invalid object, the return string will be "#invalid" if the query itself was
#  * invalid.
#  * @endforcpponly
#
proc helicsQueryCoreExecute*(l: HelicsLibrary, query: HelicsQuery, core: HelicsCore): string =
  loadSym("helicsQueryCoreExecute")
  let err = l.helicsErrorInitialize()
  result = $(f(query, core, unsafeAddr err))
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Execute a query directly on a broker.
#  *
#  * @details The call will block until the query finishes which may require communication or other delays.
#  *
#  * @param query The query object to use in the query.
#  * @param broker The broker to send the query to.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return A pointer to a string.  The string will remain valid until the query is freed or executed again.
#  * @forcpponly
#  *         The return will be nullptr if broker or query is an invalid object, the return string will be "#invalid" if the query itself was
#  * invalid
#  * @endforcpponly
#
proc helicsQueryBrokerExecute*(l: HelicsLibrary, query: HelicsQuery, broker: HelicsBroker): string =
  loadSym("helicsQueryBrokerExecute")
  let err = l.helicsErrorInitialize()
  result = $(f(query, broker, unsafeAddr err))
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Execute a query in a non-blocking call.
#  *
#  * @param query The query object to use in the query.
#  * @param fed A federate to send the query through.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsQueryExecuteAsync*(l: HelicsLibrary, query: HelicsQuery, fed: HelicsFederate) =
  loadSym("helicsQueryExecuteAsync")
  let err = l.helicsErrorInitialize()
  f(query, fed, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Complete the return from a query called with /ref helicsExecuteQueryAsync.
#  *
#  * @details The function will block until the query completes /ref isQueryComplete can be called to determine if a query has completed or
#  * not.
#  *
#  * @param query The query object to complete execution of.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @return A pointer to a string. The string will remain valid until the query is freed or executed again.
#  * @forcpponly
#  *         The return will be nullptr if query is an invalid object
#  * @endforcpponly
#
proc helicsQueryExecuteComplete*(l: HelicsLibrary, query: HelicsQuery): string =
  loadSym("helicsQueryExecuteComplete")
  let err = l.helicsErrorInitialize()
  result = $(f(query, unsafeAddr err))
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Check if an asynchronously executed query has completed.
#  *
#  * @details This function should usually be called after a QueryExecuteAsync function has been called.
#  *
#  * @param query The query object to check if completed.
#  *
#  * @return Will return helics_true if an asynchronous query has completed or a regular query call was made with a result,
#  *         and false if an asynchronous query has not completed or is invalid
#
proc helicsQueryIsCompleted*(l: HelicsLibrary, query: HelicsQuery): HelicsBool =
  loadSym("helicsQueryIsCompleted")
  result = f(query)

# *
#  * Update the target of a query.
#  *
#  * @param query The query object to change the target of.
#  * @param target the name of the target to query
#  *
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsQuerySetTarget*(l: HelicsLibrary, query: HelicsQuery, target: string) =
  loadSym("helicsQuerySetTarget")
  let err = l.helicsErrorInitialize()
  f(query, target.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Update the queryString of a query.
#  *
#  * @param query The query object to change the target of.
#  * @param queryString the new queryString
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsQuerySetQueryString*(l: HelicsLibrary, query: HelicsQuery, queryString: string) =
  loadSym("helicsQuerySetQueryString")
  let err = l.helicsErrorInitialize()
  f(query, queryString.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Free the memory associated with a query object.
#
proc helicsQueryFree*(l: HelicsLibrary, query: HelicsQuery) =
  loadSym("helicsQueryFree")
  f(query)

# *
#  * Function to do some housekeeping work.
#  *
#  * @details This runs some cleanup routines and tries to close out any residual thread that haven't been shutdown yet.
#
proc helicsCleanupLibrary*(l: HelicsLibrary) =
  loadSym("helicsCleanupLibrary")
  f()

#  MessageFederate Calls
# *
#  * Create an endpoint.
#  *
#  * @details The endpoint becomes part of the federate and is destroyed when the federate is freed
#  *          so there are no separate free functions for endpoints.
#  *
#  * @param fed The federate object in which to create an endpoint must have been created
#  *           with helicsCreateMessageFederate or helicsCreateCombinationFederate.
#  * @param name The identifier for the endpoint. This will be prepended with the federate name for the global identifier.
#  * @param type A string describing the expected type of the publication (may be NULL).
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return An object containing the endpoint.
#  * @forcpponly
#  *         nullptr on failure.
#  * @endforcpponly
#
proc helicsFederateRegisterEndpoint*(l: HelicsLibrary, fed: HelicsFederate, name: string, `type`: string): HelicsEndpoint =
  loadSym("helicsFederateRegisterEndpoint")
  let err = l.helicsErrorInitialize()
  result = f(fed, name.cstring, `type`.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Create an endpoint.
#  *
#  * @details The endpoint becomes part of the federate and is destroyed when the federate is freed
#  *          so there are no separate free functions for endpoints.
#  *
#  * @param fed The federate object in which to create an endpoint must have been created
#               with helicsCreateMessageFederate or helicsCreateCombinationFederate.
#  * @param name The identifier for the endpoint, the given name is the global identifier.
#  * @param type A string describing the expected type of the publication (may be NULL).
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  * @return An object containing the endpoint.
#  * @forcpponly
#  *         nullptr on failure.
#  * @endforcpponly
#
proc helicsFederateRegisterGlobalEndpoint*(l: HelicsLibrary, fed: HelicsFederate, name: string, `type`: string): HelicsEndpoint =
  loadSym("helicsFederateRegisterGlobalEndpoint")
  let err = l.helicsErrorInitialize()
  result = f(fed, name.cstring, `type`.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get an endpoint object from a name.
#  *
#  * @param fed The message federate object to use to get the endpoint.
#  * @param name The name of the endpoint.
#  * @forcpponly
#  * @param[in,out] err The error object to complete if there is an error.
#  * @endforcpponly
#  *
#  * @return A helics_endpoint object.
#  * @forcpponly
#  *         The object will not be valid and err will contain an error code if no endpoint with the specified name exists.
#  * @endforcpponly
#
proc helicsFederateGetEndpoint*(l: HelicsLibrary, fed: HelicsFederate, name: string): HelicsEndpoint =
  loadSym("helicsFederateGetEndpoint")
  let err = l.helicsErrorInitialize()
  result = f(fed, name, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get an endpoint by its index, typically already created via registerInterfaces file or something of that nature.
#  *
#  * @param fed The federate object in which to create a publication.
#  * @param index The index of the publication to get.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return A helics_endpoint.
#  * @forcpponly
#  *         It will be NULL if given an invalid index.
#  * @endforcpponly
#
proc helicsFederateGetEndpointByIndex*(l: HelicsLibrary, fed: HelicsFederate, index: int): HelicsEndpoint =
  loadSym("helicsFederateGetEndpointByIndex")
  let err = l.helicsErrorInitialize()
  result = f(fed, index.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Check if an endpoint is valid.
#  *
#  * @param endpoint The endpoint object to check.
#  *
#  * @return helics_true if the Endpoint object represents a valid endpoint.
#
proc helicsEndpointIsValid*(l: HelicsLibrary, endpoint: HelicsEndpoint): HelicsBool =
  loadSym("helicsEndpointIsValid")
  result = f(endpoint)

# *
#  * Set the default destination for an endpoint if no other endpoint is given.
#  *
#  * @param endpoint The endpoint to set the destination for.
#  * @param dest A string naming the desired default endpoint.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsEndpointSetDefaultDestination*(l: HelicsLibrary, endpoint: HelicsEndpoint, dest: string) =
  loadSym("helicsEndpointSetDefaultDestination")
  let err = l.helicsErrorInitialize()
  f(endpoint, dest.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get the default destination for an endpoint.
#  *
#  * @param endpoint The endpoint to set the destination for.
#  *
#  * @return A string with the default destination.
#
proc helicsEndpointGetDefaultDestination*(l: HelicsLibrary, endpoint: HelicsEndpoint): string =
  loadSym("helicsEndpointGetDefaultDestination")
  result = $(f(endpoint))

# *
#  * Send a message to the specified destination.
#  *
#  * @param endpoint The endpoint to send the data from.
#  * @param dest The target destination.
#  * @forcpponly
#  *             nullptr to use the default destination.
#  * @endforcpponly
#  * @beginpythononly
#  *             "" to use the default destination.
#  * @endpythononly
#  * @param data The data to send.
#  * @forcpponly
#  * @param inputDataLength The length of the data to send.
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsEndpointSendMessageRaw*(l: HelicsLibrary, endpoint: HelicsEndpoint, dest: string, data: pointer, inputDataLength: int) =
  loadSym("helicsEndpointSendMessageRaw")
  let err = l.helicsErrorInitialize()
  f(endpoint, dest.cstring, data, inputDataLength.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Send a message at a specific time to the specified destination.
#  *
#  * @param endpoint The endpoint to send the data from.
#  * @param dest The target destination.
#  * @forcpponly
#  *             nullptr to use the default destination.
#  * @endforcpponly
#  * @beginpythononly
#  *             "" to use the default destination.
#  * @endpythononly
#  * @param data The data to send.
#  * @forcpponly
#  * @param inputDataLength The length of the data to send.
#  * @endforcpponly
#  * @param time The time the message should be sent.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsEndpointSendEventRaw*(l: HelicsLibrary, endpoint: HelicsEndpoint, dest: string, data: pointer, inputDataLength: int, time: HelicsTime) =
  loadSym("helicsEndpointSendEventRaw")
  let err = l.helicsErrorInitialize()
  f(endpoint, dest.cstring, data, inputDataLength.cint, time, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Send a message object from a specific endpoint.
#  * @deprecated Use helicsEndpointSendMessageObject instead.
#  * @param endpoint The endpoint to send the data from.
#  * @param message The actual message to send.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsEndpointSendMessage*(l: HelicsLibrary, endpoint: HelicsEndpoint, message: ptr HelicsMessage) =
  loadSym("helicsEndpointSendMessage")
  let err = l.helicsErrorInitialize()
  f(endpoint, message, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Send a message object from a specific endpoint.
#  *
#  * @param endpoint The endpoint to send the data from.
#  * @param message The actual message to send which will be copied.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsEndpointSendMessageObject*(l: HelicsLibrary, endpoint: HelicsEndpoint, message: HelicsMessageObject) =
  loadSym("helicsEndpointSendMessageObject")
  let err = l.helicsErrorInitialize()
  f(endpoint, message, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Send a message object from a specific endpoint, the message will not be copied and the message object will no longer be valid
#  * after the call.
#  *
#  * @param endpoint The endpoint to send the data from.
#  * @param message The actual message to send which will be copied.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsEndpointSendMessageObjectZeroCopy*(l: HelicsLibrary, endpoint: HelicsEndpoint, message: HelicsMessageObject) =
  loadSym("helicsEndpointSendMessageObjectZeroCopy")
  let err = l.helicsErrorInitialize()
  f(endpoint, message, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))


# *
#  * Subscribe an endpoint to a publication.
#  *
#  * @param endpoint The endpoint to use.
#  * @param key The name of the publication.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsEndpointSubscribe*(l: HelicsLibrary, endpoint: HelicsEndpoint, key: string) =
  loadSym("helicsEndpointSubscribe")
  let err = l.helicsErrorInitialize()
  f(endpoint, key, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Check if the federate has any outstanding messages.
#  *
#  * @param fed The federate to check.
#  *
#  * @return helics_true if the federate has a message waiting, helics_false otherwise.
#
proc helicsFederateHasMessage*(l: HelicsLibrary, fed: HelicsFederate): HelicsBool =
  loadSym("helicsFederateHasMessage")
  f(fed)

# *
#  * Check if a given endpoint has any unread messages.
#  *
#  * @param endpoint The endpoint to check.
#  *
#  * @return helics_true if the endpoint has a message, helics_false otherwise.
#
proc helicsEndpointHasMessage*(l: HelicsLibrary, endpoint: HelicsEndpoint): HelicsBool =
  loadSym("helicsEndpointHasMessage")
  f(endpoint)

# *
#  * Returns the number of pending receives for the specified destination endpoint.
#  *
#  * @param fed The federate to get the number of waiting messages from.
#
proc helicsFederatePendingMessages*(l: HelicsLibrary, fed: HelicsFederate): int =
  loadSym("helicsFederatePendingMessages")
  f(fed)

# *
#  * Returns the number of pending receives for all endpoints of a particular federate.
#  *
#  * @param endpoint The endpoint to query.
#
proc helicsEndpointPendingMessages*(l: HelicsLibrary, endpoint: HelicsEndpoint): int =
  loadSym("helicsEndpointPendingMessages")
  f(endpoint)

# *
#  * Receive a packet from a particular endpoint.
#  *
#  * @deprecated This function is deprecated and will be removed in Helics 3.0.
#  *             Use helicsEndpointGetMessageObject instead.
#  *
#  * @param[in] endpoint The identifier for the endpoint.
#  *
#  * @return A message object.
#
proc helicsEndpointGetMessage*(l: HelicsLibrary, endpoint: HelicsEndpoint): HelicsMessage =
  loadSym("helicsEndpointGetMessage")
  f(endpoint)

# *
#  * Receive a packet from a particular endpoint.
#  *
#  * @param[in] endpoint The identifier for the endpoint.
#  *
#  * @return A message object.
#
proc helicsEndpointGetMessageObject*(l: HelicsLibrary, endpoint: HelicsEndpoint): HelicsMessageObject =
  loadSym("helicsEndpointGetMessageObject")
  f(endpoint)

# *
#  * Create a new empty message object.
#  *
#  * @details The message is empty and isValid will return false since there is no data associated with the message yet.
#  *
#  * @param endpoint The endpoint object to associate the message with.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#  *
#  * @return A new helics_message_object.
#
proc helicsEndpointCreateMessageObject*(l: HelicsLibrary, endpoint: HelicsEndpoint): HelicsMessageObject =
  loadSym("helicsEndpointCreateMessageObject")
  let err = l.helicsErrorInitialize()
  result = f(endpoint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Receive a communication message for any endpoint in the federate.
#  *
#  * @deprecated This function is deprecated and will be removed in Helics 3.0.
#  *             Use helicsFederateGetMessageObject instead.
#  *
#  * @details The return order will be in order of endpoint creation.
#  *          So all messages that are available for the first endpoint, then all for the second, and so on.
#  *          Within a single endpoint, the messages are ordered by time, then source_id, then order of arrival.
#  *
#  * @return A unique_ptr to a Message object containing the message data.
#
proc helicsFederateGetMessage*(l: HelicsLibrary, fed: HelicsFederate): HelicsMessage =
  loadSym("helicsFederateGetMessage")
  f(fed)

# *
#  * Receive a communication message for any endpoint in the federate.
#  *
#  * @details The return order will be in order of endpoint creation.
#  *          So all messages that are available for the first endpoint, then all for the second, and so on.
#  *          Within a single endpoint, the messages are ordered by time, then source_id, then order of arrival.
#  *
#  * @return A helics_message_object which references the data in the message.
#
proc helicsFederateGetMessageObject*(l: HelicsLibrary, fed: HelicsFederate): HelicsMessageObject =
  loadSym("helicsFederateGetMessageObject")
  f(fed)

# *
#  * Create a new empty message object.
#  *
#  * @details The message is empty and isValid will return false since there is no data associated with the message yet.
#  *
#  * @param fed the federate object to associate the message with
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#  *
#  * @return A helics_message_object containing the message data.
#
proc helicsFederateCreateMessageObject*(l: HelicsLibrary, fed: HelicsFederate): HelicsMessageObject =
  loadSym("helicsFederateCreateMessageObject")
  let err = l.helicsErrorInitialize()
  result = f(fed, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Clear all stored messages from a federate.
#  *
#  * @details This clears messages retrieved through helicsFederateGetMessage or helicsFederateGetMessageObject
#  *
#  * @param fed The federate to clear the message for.
#
proc helicsFederateClearMessages*(l: HelicsLibrary, fed: HelicsFederate) =
  loadSym("helicsFederateClearMessages")
  f(fed)

# *
#  * Clear all message from an endpoint.
#  *
#  * @deprecated This function does nothing and will be removed.
#  *             Use helicsFederateClearMessages to free all messages,
#  *             or helicsMessageFree to clear an individual message.
#  *
#  * @param endpoint The endpoint object to operate on.
#
proc helicsEndpointClearMessages*(l: HelicsLibrary, endpoint: HelicsEndpoint) =
  loadSym("helicsEndpointClearMessages")
  f(endpoint)

# *
#  * Get the type specified for an endpoint.
#  *
#  * @param endpoint The endpoint object in question.
#  *
#  * @return The defined type of the endpoint.
#
proc helicsEndpointGetType*(l: HelicsLibrary, endpoint: HelicsEndpoint): string =
  loadSym("helicsEndpointGetType")
  result = $(f(endpoint))

# *
#  * Get the name of an endpoint.
#  *
#  * @param endpoint The endpoint object in question.
#  *
#  * @return The name of the endpoint.
#
proc helicsEndpointGetName*(l: HelicsLibrary, endpoint: HelicsEndpoint): string =
  loadSym("helicsEndpointGetName")
  result = $(f(endpoint))

# *
#  * Get the number of endpoints in a federate.
#  *
#  * @param fed The message federate to query.
#  *
#  * @return (-1) if fed was not a valid federate, otherwise returns the number of endpoints.
#
proc helicsFederateGetEndpointCount*(l: HelicsLibrary, fed: HelicsFederate): int =
  loadSym("helicsFederateGetEndpointCount")
  result = f(fed).int

# *
#  * Get the data in the info field of a filter.
#  *
#  * @param end The filter to query.
#  *
#  * @return A string with the info field string.
#
proc helicsEndpointGetInfo*(l: HelicsLibrary, endpoint: HelicsEndpoint): string =
  loadSym("helicsEndpointGetInfo")
  result = $(f(endpoint))

# *
#  * Set the data in the info field for a filter.
#  *
#  * @param end The endpoint to query.
#  * @param info The string to set.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsEndpointSetInfo*(l: HelicsLibrary, endpoint: HelicsEndpoint, info: string) =
  loadSym("helicsEndpointSetInfo")
  let err = l.helicsErrorInitialize()
  f(endpoint, info.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set a handle option on an endpoint.
#  *
#  * @param end The endpoint to modify.
#  * @param option Integer code for the option to set /ref helics_handle_options.
#  * @param value The value to set the option to.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsEndpointSetOption*(l: HelicsLibrary, endpoint: HelicsEndpoint, option: int, value: int) =
  loadSym("helicsEndpointSetOption")
  let err = l.helicsErrorInitialize()
  f(endpoint, option.cint, value.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set a handle option on an endpoint.
#  *
#  * @param end The endpoint to modify.
#  * @param option Integer code for the option to set /ref helics_handle_options.
#  * @return the value of the option, for boolean options will be 0 or 1
#
proc helicsEndpointGetOption*(l: HelicsLibrary, endpoint: HelicsEndpoint, option: int): int =
  loadSym("helicsEndpointGetOption")
  result = f(endpoint, option.cint).int

# *
#  * \defgroup Message operation functions
#  * @details Functions for working with helics message envelopes.
#  * @{
#
# *
#  * Get the source endpoint of a message.
#  *
#  * @param message The message object in question.
#  *
#  * @return A string with the source endpoint.
#
proc helicsMessageGetSource*(l: HelicsLibrary, message: HelicsMessageObject): string =
  loadSym("helicsMessageGetSource")
  result = $(f(message))

# *
#  * Get the destination endpoint of a message.
#  *
#  * @param message The message object in question.
#  *
#  * @return A string with the destination endpoint.
#
proc helicsMessageGetDestination*(l: HelicsLibrary, message: HelicsMessageObject): string =
  loadSym("helicsMessageGetDestination")
  result = $(f(message))

# *
#  * Get the original source endpoint of a message, the source may have been modified by filters or other actions.
#  *
#  * @param message The message object in question.
#  *
#  * @return A string with the source of a message.
#
proc helicsMessageGetOriginalSource*(l: HelicsLibrary, message: HelicsMessageObject): string =
  loadSym("helicsMessageGetOriginalSource")
  result = $(f(message))

# *
#  * Get the original destination endpoint of a message, the destination may have been modified by filters or other actions.
#  *
#  * @param message The message object in question.
#  *
#  * @return A string with the original destination of a message.
#
proc helicsMessageGetOriginalDestination*(l: HelicsLibrary, message: HelicsMessageObject): string =
  loadSym("helicsMessageGetOriginalDestination")
  result = $(f(message))

# *
#  * Get the helics time associated with a message.
#  *
#  * @param message The message object in question.
#  *
#  * @return The time associated with a message.
#
proc helicsMessageGetTime*(l: HelicsLibrary, message: HelicsMessageObject): HelicsTime =
  loadSym("helicsMessageGetTime")
  result = f(message)

# *
#  * Get the payload of a message as a string.
#  *
#  * @param message The message object in question.
#  *
#  * @return A string representing the payload of a message.
#
proc helicsMessageGetString*(l: HelicsLibrary, message: HelicsMessageObject): string =
  loadSym("helicsMessageGetString")
  result = $(f(message))

# *
#  * Get the messageID of a message.
#  *
#  * @param message The message object in question.
#  *
#  * @return The messageID.
#
proc helicsMessageGetMessageID*(l: HelicsLibrary, message: HelicsMessageObject): int =
  loadSym("helicsMessageGetMessageID")
  result = f(message).int

# *
#  * Check if a flag is set on a message.
#  *
#  * @param message The message object in question.
#  * @param flag The flag to check should be between [0,15].
#  *
#  * @return The flags associated with a message.
#
proc helicsMessageCheckFlag*(l: HelicsLibrary, message: HelicsMessageObject, flag: int): HelicsBool =
  loadSym("helicsMessageCheckFlag")
  result = f(message, flag.cint)

# *
#  * Get the size of the data payload in bytes.
#  *
#  * @param message The message object in question.
#  *
#  * @return The size of the data payload.
#
proc helicsMessageGetRawDataSize*(l: HelicsLibrary, message: HelicsMessageObject): int =
  loadSym("helicsMessageGetRawDataSize")
  result = f(message).int

# *
#  * Get the raw data for a message object.
#  *
#  * @param message A message object to get the data for.
#  * @forcpponly
#  * @param[out] data The memory location of the data.
#  * @param maxMessagelen The maximum size of information that data can hold.
#  * @param[out] actualSize The actual length of data copied to data.
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @beginPythonOnly
#  * @return Raw string data.
#  * @endPythonOnly
#
proc helicsMessageGetRawData*(l: HelicsLibrary, message: HelicsMessageObject, data: pointer, maxMessagelen: int, actualSize: ptr cint, err:ptr HelicsError) =
  loadSym("helicsMessageGetRawData")
  let err = l.helicsErrorInitialize()
  f(message, data, maxMessagelen.cint, actualSize, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get a pointer to the raw data of a message.
#  *
#  * @param message A message object to get the data for.
#  *
#  * @return A pointer to the raw data in memory, the pointer may be NULL if the message is not a valid message.
#
proc helicsMessageGetRawDataPointer*(l: HelicsLibrary, message: HelicsMessageObject): pointer =
  loadSym("helicsMessageGetRawDataPointer")
  result = f(message)

# *
#  * A check if the message contains a valid payload.
#  *
#  * @param message The message object in question.
#  *
#  * @return helics_true if the message contains a payload.
#
proc helicsMessageIsValid*(l: HelicsLibrary, message: HelicsMessageObject): HelicsBool =
  loadSym("helicsMessageIsValid")
  result = f(message)

# *
#  * Set the source of a message.
#  *
#  * @param message The message object in question.
#  * @param src A string containing the source.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsMessageSetSource*(l: HelicsLibrary, message: HelicsMessageObject, src: string) =
  loadSym("helicsMessageSetSource")
  let err = l.helicsErrorInitialize()
  f(message, src.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the destination of a message.
#  *
#  * @param message The message object in question.
#  * @param dest A string containing the new destination.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsMessageSetDestination*(l: HelicsLibrary, message: HelicsMessageObject, dest: string) =
  loadSym("helicsMessageSetDestination")
  let err = l.helicsErrorInitialize()
  f(message, dest.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the original source of a message.
#  *
#  * @param message The message object in question.
#  * @param src A string containing the new original source.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsMessageSetOriginalSource*(l: HelicsLibrary, message: HelicsMessageObject, src: string) =
  loadSym("helicsMessageSetOriginalSource")
  let err = l.helicsErrorInitialize()
  f(message, src.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the original destination of a message.
#  *
#  * @param message The message object in question.
#  * @param dest A string containing the new original source.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsMessageSetOriginalDestination*(l: HelicsLibrary, message: HelicsMessageObject, dest: string) =
  loadSym("helicsMessageSetOriginalDestination")
  let err = l.helicsErrorInitialize()
  f(message, dest.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the delivery time for a message.
#  *
#  * @param message The message object in question.
#  * @param time The time the message should be delivered.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsMessageSetTime*(l: HelicsLibrary, message: HelicsMessageObject, time: HelicsTime) =
  loadSym("helicsMessageSetTime")
  let err = l.helicsErrorInitialize()
  f(message, time, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Resize the data buffer for a message.
#  *
#  * @details The message data buffer will be resized. There are no guarantees on what is in the buffer in newly allocated space.
#  *          If the allocated space is not sufficient new allocations will occur.
#  *
#  * @param message The message object in question.
#  * @param newSize The new size in bytes of the buffer.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsMessageResize*(l: HelicsLibrary, message: HelicsMessageObject, newSize: int) =
  loadSym("helicsMessageResize")
  let err = l.helicsErrorInitialize()
  f(message, newSize.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Reserve space in a buffer but don't actually resize.
#  *
#  * @details The message data buffer will be reserved but not resized.
#  *
#  * @param message The message object in question.
#  * @param reserveSize The number of bytes to reserve in the message object.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsMessageReserve*(l: HelicsLibrary, message: HelicsMessageObject, reserveSize: int) =
  loadSym("helicsMessageReserve")
  let err = l.helicsErrorInitialize()
  f(message, reserveSize.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the message ID for the message.
#  *
#  * @details Normally this is not needed and the core of HELICS will adjust as needed.
#  *
#  * @param message The message object in question.
#  * @param messageID A new message ID.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsMessageSetMessageID*(l: HelicsLibrary, message: HelicsMessageObject, messageID: int32) =
  loadSym("helicsMessageSetMessageID")
  let err = l.helicsErrorInitialize()
  f(message, messageID.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Clear the flags of a message.
#  *
#  * @param message The message object in question
#
proc helicsMessageClearFlags*(l: HelicsLibrary, message: HelicsMessageObject) =
  loadSym("helicsMessageClearFlags")
  f(message)

# *
#  * Set a flag on a message.
#  *
#  * @param message The message object in question.
#  * @param flag An index of a flag to set on the message.
#  * @param flagValue The desired value of the flag.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsMessageSetFlagOption*(l: HelicsLibrary, message: HelicsMessageObject, flag: int, flagValue: HelicsBool) =
  loadSym("helicsMessageSetFlagOption")
  let err = l.helicsErrorInitialize()
  f(message, flag.cint, flagValue, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the data payload of a message as a string.
#  *
#  * @param message The message object in question.
#  * @param str A string containing the message data.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsMessageSetString*(l: HelicsLibrary, message: HelicsMessageObject, str: string) =
  loadSym("helicsMessageSetString")
  let err = l.helicsErrorInitialize()
  f(message, str.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the data payload of a message as raw data.
#  *
#  * @param message The message object in question.
#  * @param data A string containing the message data.
#  * @param inputDataLength The length of the data to input.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsMessageSetData*(l: HelicsLibrary, message: HelicsMessageObject, data: pointer, inputDataLength: int) =
  loadSym("helicsMessageSetData")
  let err = l.helicsErrorInitialize()
  f(message, data, inputDataLength.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Append data to the payload.
#  *
#  * @param message The message object in question.
#  * @param data A string containing the message data to append.
#  * @param inputDataLength The length of the data to input.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsMessageAppendData*(l: HelicsLibrary, message: HelicsMessageObject, data: pointer, inputDataLength: int) =
  loadSym("helicsMessageAppendData")
  let err = l.helicsErrorInitialize()
  f(message, data, inputDataLength.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Copy a message object.
#  *
#  * @param source_message The message object to copy from.
#  * @param dest_message The message object to copy to.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsMessageCopy*(l: HelicsLibrary, source_message: HelicsMessageObject, dest_message: HelicsMessageObject) =
  loadSym("helicsMessageCopy")
  let err = l.helicsErrorInitialize()
  f(source_message, dest_message, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Clone a message object.
#  *
#  * @param message The message object to copy from.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsMessageClone*(l: HelicsLibrary, message: HelicsMessageObject): HelicsMessageObject =
  loadSym("helicsMessageClone")
  let err = l.helicsErrorInitialize()
  result = f(message, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Free a message object from memory
#  * @details memory for message is managed so not using this function does not create memory leaks, this is an indication
#  * to the system that the memory for this message is done being used and can be reused for a new message.
#  * helicsFederateClearMessages() can also be used to clear up all stored messages at once
#
proc helicsMessageFree*(l: HelicsLibrary, message: HelicsMessageObject) =
  loadSym("helicsMessageFree")
  f(message)

# *@}
#
# Copyright (c) 2017-2020,
# Battelle Memorial Institute; Lawrence Livermore National Security, LLC; Alliance for Sustainable Energy, LLC.  See the top-level NOTICE for
# additional details. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause
#
# *
#  * @file
#  *
# @brief Functions related to message filters for the C api
#
# *
#  * Create a source Filter on the specified federate.
#  *
#  * @details Filters can be created through a federate or a core, linking through a federate allows
#  *          a few extra features of name matching to function on the federate interface but otherwise equivalent behavior
#  *
#  * @param fed The federate to register through.
#  * @param type The type of filter to create /ref helics_filter_type.
#  * @param name The name of the filter (can be NULL).
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return A helics_filter object.
#
proc helicsFederateRegisterFilter*(l: HelicsLibrary, fed: HelicsFederate, `type`: HelicsFilterType, name: string): HelicsFilter =
  loadSym("helicsFederateRegisterFilter")
  let err = l.helicsErrorInitialize()
  result = f(fed, `type`, name.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Create a global source filter through a federate.
#  *
#  * @details Filters can be created through a federate or a core, linking through a federate allows
#  *          a few extra features of name matching to function on the federate interface but otherwise equivalent behavior.
#  *
#  * @param fed The federate to register through.
#  * @param type The type of filter to create /ref helics_filter_type.
#  * @param name The name of the filter (can be NULL).
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return A helics_filter object.
#
proc helicsFederateRegisterGlobalFilter*(l: HelicsLibrary, fed: HelicsFederate, `type`: HelicsFilterType, name: string): HelicsFilter =
  loadSym("helicsFederateRegisterGlobalFilter")
  let err = l.helicsErrorInitialize()
  result = f(fed, `type`, name.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Create a cloning Filter on the specified federate.
#  *
#  * @details Cloning filters copy a message and send it to multiple locations, source and destination can be added
#  *          through other functions.
#  *
#  * @param fed The federate to register through.
#  * @param name The name of the filter (can be NULL).
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return A helics_filter object.
#
proc helicsFederateRegisterCloningFilter*(l: HelicsLibrary, fed: HelicsFederate, name: string): HelicsFilter =
  loadSym("helicsFederateRegisterCloningFilter")
  let err = l.helicsErrorInitialize()
  result = f(fed, name.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Create a global cloning Filter on the specified federate.
#  *
#  * @details Cloning filters copy a message and send it to multiple locations, source and destination can be added
#  *          through other functions.
#  *
#  * @param fed The federate to register through.
#  * @param name The name of the filter (can be NULL).
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return A helics_filter object.
#
proc helicsFederateRegisterGlobalCloningFilter*(l: HelicsLibrary, fed: HelicsFederate, name: string): HelicsFilter =
  loadSym("helicsFederateRegisterGlobalCloningFilter")
  let err = l.helicsErrorInitialize()
  result = f(fed, name.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Create a source Filter on the specified core.
#  *
#  * @details Filters can be created through a federate or a core, linking through a federate allows
#  *          a few extra features of name matching to function on the federate interface but otherwise equivalent behavior.
#  *
#  * @param core The core to register through.
#  * @param type The type of filter to create /ref helics_filter_type.
#  * @param name The name of the filter (can be NULL).
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return A helics_filter object.
#
proc helicsCoreRegisterFilter*(l: HelicsLibrary, core: HelicsCore, `type`: HelicsFilterType, name: string): HelicsFilter =
  loadSym("helicsCoreRegisterFilter")
  let err = l.helicsErrorInitialize()
  result = f(core, `type`, name.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Create a cloning Filter on the specified core.
#  *
#  * @details Cloning filters copy a message and send it to multiple locations, source and destination can be added
#  *          through other functions.
#  *
#  * @param core The core to register through.
#  * @param name The name of the filter (can be NULL).
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return A helics_filter object.
#
proc helicsCoreRegisterCloningFilter*(l: HelicsLibrary, core: HelicsCore, name: string): HelicsFilter =
  loadSym("helicsCoreRegisterCloningFilter")
  let err = l.helicsErrorInitialize()
  result = f(core, name.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get the number of filters registered through a federate.
#  *
#  * @param fed The federate object to use to get the filter.
#  *
#  * @return A count of the number of filters registered through a federate.
#
proc helicsFederateGetFilterCount*(l: HelicsLibrary, fed: HelicsFederate): int =
  loadSym("helicsFederateGetFilterCount")
  f(fed)

# *
#  * Get a filter by its name, typically already created via registerInterfaces file or something of that nature.
#  *
#  * @param fed The federate object to use to get the filter.
#  * @param name The name of the filter.
#  * @forcpponly
#  * @param[in,out] err The error object to complete if there is an error.
#  * @endforcpponly
#  *
#  * @return A helics_filter object, the object will not be valid and err will contain an error code if no filter with the specified name
#  * exists.
#
proc helicsFederateGetFilter*(l: HelicsLibrary, fed: HelicsFederate, name: string): HelicsFilter =
  loadSym("helicsFederateGetFilter")
  let err = l.helicsErrorInitialize()
  result = f(fed, name.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get a filter by its index, typically already created via registerInterfaces file or something of that nature.
#  *
#  * @param fed The federate object in which to create a publication.
#  * @param index The index of the publication to get.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return A helics_filter, which will be NULL if an invalid index is given.
#
proc helicsFederateGetFilterByIndex*(l: HelicsLibrary, fed: HelicsFederate, index: int): HelicsFilter =
  loadSym("helicsFederateGetFilterByIndex")
  let err = l.helicsErrorInitialize()
  result = f(fed, index.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Check if a filter is valid.
#  *
#  * @param filt The filter object to check.
#  *
#  * @return helics_true if the Filter object represents a valid filter.
#
proc helicsFilterIsValid*(l: HelicsLibrary, filt: HelicsFilter): HelicsBool =
  loadSym("helicsFilterIsValid")
  f(filt)

# *
#  * Get the name of the filter and store in the given string.
#  *
#  * @param filt The given filter.
#  *
#  * @return A string with the name of the filter.
#
proc helicsFilterGetName*(l: HelicsLibrary, filt: HelicsFilter): string =
  loadSym("helicsFilterGetName")
  result = $(f(filt))

# *
#  * Set a property on a filter.
#  *
#  * @param filt The filter to modify.
#  * @param prop A string containing the property to set.
#  * @param val A numerical value for the property.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsFilterSet*(l: HelicsLibrary, filt: HelicsFilter, prop: string, val: float) =
  loadSym("helicsFilterSet")
  let err = l.helicsErrorInitialize()
  f(filt, prop.cstring, val.cdouble, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set a string property on a filter.
#  *
#  * @param filt The filter to modify.
#  * @param prop A string containing the property to set.
#  * @param val A string containing the new value.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsFilterSetString*(l: HelicsLibrary, filt: HelicsFilter, prop: string, val: string) =
  loadSym("helicsFilterSetString")
  let err = l.helicsErrorInitialize()
  f(filt, prop.cstring, val.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Add a destination target to a filter.
#  *
#  * @details All messages going to a destination are copied to the delivery address(es).
#  * @param filt The given filter to add a destination target to.
#  * @param dest The name of the endpoint to add as a destination target.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsFilterAddDestinationTarget*(l: HelicsLibrary, filt: HelicsFilter, dest: string) =
  loadSym("helicsFilterAddDestinationTarget")
  let err = l.helicsErrorInitialize()
  f(filt, dest.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Add a source target to a filter.
#  *
#  * @details All messages coming from a source are copied to the delivery address(es).
#  *
#  * @param filt The given filter.
#  * @param source The name of the endpoint to add as a source target.
#  * @forcpponly.
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsFilterAddSourceTarget*(l: HelicsLibrary, filt: HelicsFilter, source: string) =
  loadSym("helicsFilterAddSourceTarget")
  let err = l.helicsErrorInitialize()
  f(filt, source.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * \defgroup Clone filter functions
#  * @details Functions that manipulate cloning filters in some way.
#  * @{
#
# *
#  * Add a delivery endpoint to a cloning filter.
#  *
#  * @details All cloned messages are sent to the delivery address(es).
#  *
#  * @param filt The given filter.
#  * @param deliveryEndpoint The name of the endpoint to deliver messages to.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsFilterAddDeliveryEndpoint*(l: HelicsLibrary, filt: HelicsFilter, deliveryEndpoint: string) =
  loadSym("helicsFilterAddDeliveryEndpoint")
  let err = l.helicsErrorInitialize()
  f(filt, deliveryEndpoint.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Remove a destination target from a filter.
#  *
#  * @param filt The given filter.
#  * @param target The named endpoint to remove as a target.
#  * @forcpponly
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsFilterRemoveTarget*(l: HelicsLibrary, filt: HelicsFilter, target: string) =
  loadSym("helicsFilterRemoveTarget")
  let err = l.helicsErrorInitialize()
  f(filt, target.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Remove a delivery destination from a cloning filter.
#  *
#  * @param filt The given filter (must be a cloning filter).
#  * @param deliveryEndpoint A string with the delivery endpoint to remove.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsFilterRemoveDeliveryEndpoint*(l: HelicsLibrary, filt: HelicsFilter, deliveryEndpoint: string) =
  loadSym("helicsFilterRemoveDeliveryEndpoint")
  let err = l.helicsErrorInitialize()
  f(filt, deliveryEndpoint.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get the data in the info field of a filter.
#  *
#  * @param filt The given filter.
#  *
#  * @return A string with the info field string.
#
proc helicsFilterGetInfo*(l: HelicsLibrary, filt: HelicsFilter): string =
  loadSym("helicsFilterGetInfo")
  result = $(f(filt))

# *
#  * Set the data in the info field for a filter.
#  *
#  * @param filt The given filter.
#  * @param info The string to set.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsFilterSetInfo*(l: HelicsLibrary, filt: HelicsFilter, info: string) =
  loadSym("helicsFilterSetInfo")
  let err = l.helicsErrorInitialize()
  f(filt, info.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the data in the info field for a filter.
#  *
#  * @param filt The given filter.
#  * @param option The option to set /ref helics_handle_options.
#  * @param value The value of the option commonly 0 for false 1 for true.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsFilterSetOption*(l: HelicsLibrary, filt: HelicsFilter, option: int, value: int) =
  loadSym("helicsFilterSetOption")
  let err = l.helicsErrorInitialize()
  f(filt, option.cint, value.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get a handle option for the filter.
#  *
#  * @param filt The given filter to query.
#  * @param option The option to query /ref helics_handle_options.
#
proc helicsFilterGetOption*(l: HelicsLibrary, filt: HelicsFilter, option: int): int =
  loadSym("helicsFilterGetOption")
  result = f(filt, option.cint).int

# *
#  * @}
#
#
# Copyright (c) 2017-2020,
# Battelle Memorial Institute; Lawrence Livermore National Security, LLC; Alliance for Sustainable Energy, LLC.  See the top-level NOTICE for
# additional details. All rights reserved.
# SPDX-License-Identifier: BSD-3-Clause
#
# *
#  * @file
#  *
#  * @brief Functions related to value federates for the C api
#
# *
#  * sub/pub registration
#
# *
#  * Create a subscription.
#  *
#  * @details The subscription becomes part of the federate and is destroyed when the federate is freed so there are no separate free
#  * functions for subscriptions and publications.
#  *
#  * @param fed The federate object in which to create a subscription, must have been created with /ref helicsCreateValueFederate or
#  * /ref helicsCreateCombinationFederate.
#  * @param key The identifier matching a publication to get a subscription for.
#  * @param units A string listing the units of the subscription (may be NULL).
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return An object containing the subscription.
#
proc helicsFederateRegisterSubscription*(l: HelicsLibrary, fed: HelicsFederate, key: string, units: string): HelicsInput =
  loadSym("helicsFederateRegisterSubscription")
  let err = l.helicsErrorInitialize()
  result = f(fed, key.cstring, units.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Register a publication with a known type.
#  *
#  * @details The publication becomes part of the federate and is destroyed when the federate is freed so there are no separate free
#  * functions for subscriptions and publications.
#  *
#  * @param fed The federate object in which to create a publication.
#  * @param key The identifier for the publication the global publication key will be prepended with the federate name.
#  * @param type A code identifying the type of the input see /ref helics_data_type for available options.
#  * @param units A string listing the units of the subscription (may be NULL).
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return An object containing the publication.
#
proc helicsFederateRegisterPublication*(l: HelicsLibrary, fed: HelicsFederate, key: string, `type`: HelicsDataType, units: string): HelicsPublication =
  loadSym("helicsFederateRegisterPublication")
  let err = l.helicsErrorInitialize()
  result = f(fed, key.cstring, `type`, units.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Register a publication with a defined type.
#  *
#  * @details The publication becomes part of the federate and is destroyed when the federate is freed so there are no separate free
#  * functions for subscriptions and publications.
#  *
#  * @param fed The federate object in which to create a publication.
#  * @param key The identifier for the publication.
#  * @param type A string labeling the type of the publication.
#  * @param units A string listing the units of the subscription (may be NULL).
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return An object containing the publication.
#
proc helicsFederateRegisterTypePublication*(l: HelicsLibrary, fed: HelicsFederate, key: string, `type`: string, units: string): HelicsPublication =
  loadSym("helicsFederateRegisterTypePublication")
  let err = l.helicsErrorInitialize()
  result = f(fed, key.cstring, `type`.cstring, units.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Register a global named publication with an arbitrary type.
#  *
#  * @details The publication becomes part of the federate and is destroyed when the federate is freed so there are no separate free
#  * functions for subscriptions and publications.
#  *
#  * @param fed The federate object in which to create a publication.
#  * @param key The identifier for the publication.
#  * @param type A code identifying the type of the input see /ref helics_data_type for available options.
#  * @param units A string listing the units of the subscription (may be NULL).
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return An object containing the publication.
#
proc helicsFederateRegisterGlobalPublication*(l: HelicsLibrary, fed: HelicsFederate, key: string, `type`: HelicsDataType, units: string): HelicsPublication =
  loadSym("helicsFederateRegisterGlobalPublication")
  let err = l.helicsErrorInitialize()
  result = f(fed, key.cstring, `type`, units.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Register a global publication with a defined type.
#  *
#  * @details The publication becomes part of the federate and is destroyed when the federate is freed so there are no separate free
#  * functions for subscriptions and publications.
#  *
#  * @param fed The federate object in which to create a publication.
#  * @param key The identifier for the publication.
#  * @param type A string describing the expected type of the publication.
#  * @param units A string listing the units of the subscription (may be NULL).
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return An object containing the publication.
#
proc helicsFederateRegisterGlobalTypePublication*(l: HelicsLibrary, fed: HelicsFederate, key: string, `type`: string, units: string, err:ptr HelicsError): HelicsPublication =
  loadSym("helicsFederateRegisterGlobalTypePublication")
  let err = l.helicsErrorInitialize()
  result = f(fed, key.cstring, `type`.cstring, units.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Register a named input.
#  *
#  * @details The input becomes part of the federate and is destroyed when the federate is freed so there are no separate free
#  * functions for subscriptions, inputs, and publications.
#  *
#  * @param fed The federate object in which to create an input.
#  * @param key The identifier for the publication the global input key will be prepended with the federate name.
#  * @param type A code identifying the type of the input see /ref helics_data_type for available options.
#  * @param units A string listing the units of the input (may be NULL).
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return An object containing the input.
#
proc helicsFederateRegisterInput*(l: HelicsLibrary, fed: HelicsFederate, key: string, `type`: HelicsDataType, units: string): HelicsInput =
  loadSym("helicsFederateRegisterInput")
  let err = l.helicsErrorInitialize()
  result = f(fed, key.cstring, `type`, units.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Register an input with a defined type.
#  *
#  * @details The input becomes part of the federate and is destroyed when the federate is freed so there are no separate free
#  * functions for subscriptions, inputs, and publications.
#  *
#  * @param fed The federate object in which to create an input.
#  * @param key The identifier for the input.
#  * @param type A string describing the expected type of the input.
#  * @param units A string listing the units of the input maybe NULL.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return An object containing the publication.
#
proc helicsFederateRegisterTypeInput*(l: HelicsLibrary, fed: HelicsFederate, key: string, `type`: string, units: string): HelicsInput =
  loadSym("helicsFederateRegisterTypeInput")
  let err = l.helicsErrorInitialize()
  result = f(fed, key.cstring, `type`.cstring, units.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Register a global named input.
#  *
#  * @details The publication becomes part of the federate and is destroyed when the federate is freed so there are no separate free
#  * functions for subscriptions and publications.
#  *
#  * @param fed The federate object in which to create a publication.
#  * @param key The identifier for the publication.
#  * @param type A code identifying the type of the input see /ref helics_data_type for available options.
#  * @param units A string listing the units of the subscription maybe NULL.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return An object containing the publication.
#
proc helicsFederateRegisterGlobalInput*(l: HelicsLibrary, fed: HelicsFederate, key: string, `type`: HelicsDataType, units: string): HelicsPublication =
  loadSym("helicsFederateRegisterGlobalInput")
  let err = l.helicsErrorInitialize()
  result = f(fed, key.cstring, `type`, units.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Register a global publication with an arbitrary type.
#  *
#  * @details The publication becomes part of the federate and is destroyed when the federate is freed so there are no separate free
#  * functions for subscriptions and publications.
#  *
#  * @param fed The federate object in which to create a publication.
#  * @param key The identifier for the publication.
#  * @param type A string defining the type of the input.
#  * @param units A string listing the units of the subscription maybe NULL.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return An object containing the publication.
#
proc helicsFederateRegisterGlobalTypeInput*(l: HelicsLibrary, fed: HelicsFederate, key: string, `type`: string, units: string): HelicsPublication =
  loadSym("helicsFederateRegisterGlobalTypeInput")
  let err = l.helicsErrorInitialize()
  result = f(fed, key.cstring, `type`.cstring, units.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get a publication object from a key.
#  *
#  * @param fed The value federate object to use to get the publication.
#  * @param key The name of the publication.
#  * @forcpponly
#  * @param[in,out] err The error object to complete if there is an error.
#  * @endforcpponly
#  *
#  * @return A helics_publication object, the object will not be valid and err will contain an error code if no publication with the
#  * specified key exists.
#
proc helicsFederateGetPublication*(l: HelicsLibrary, fed: HelicsFederate, key: string): HelicsPublication =
  loadSym("helicsFederateGetPublication")
  let err = l.helicsErrorInitialize()
  result = f(fed, key.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get a publication by its index, typically already created via registerInterfaces file or something of that nature.
#  *
#  * @param fed The federate object in which to create a publication.
#  * @param index The index of the publication to get.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return A helics_publication.
#
proc helicsFederateGetPublicationByIndex*(l: HelicsLibrary, fed: HelicsFederate, index: int): HelicsPublication =
  loadSym("helicsFederateGetPublicationByIndex")
  let err = l.helicsErrorInitialize()
  result = f(fed, index.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get an input object from a key.
#  *
#  * @param fed The value federate object to use to get the publication.
#  * @param key The name of the input.
#  * @forcpponly
#  * @param[in,out] err The error object to complete if there is an error.
#  * @endforcpponly
#  *
#  * @return A helics_input object, the object will not be valid and err will contain an error code if no input with the specified
#  * key exists.
#
proc helicsFederateGetInput*(l: HelicsLibrary, fed: HelicsFederate, key: string): HelicsInput =
  loadSym("helicsFederateGetInput")
  let err = l.helicsErrorInitialize()
  result = f(fed, key.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get an input by its index, typically already created via registerInterfaces file or something of that nature.
#  *
#  * @param fed The federate object in which to create a publication.
#  * @param index The index of the publication to get.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return A helics_input, which will be NULL if an invalid index.
#
proc helicsFederateGetInputByIndex*(l: HelicsLibrary, fed: HelicsFederate, index: int): HelicsInput =
  loadSym("helicsFederateGetInputByIndex")
  let err = l.helicsErrorInitialize()
  result = f(fed, index.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get an input object from a subscription target.
#  *
#  * @param fed The value federate object to use to get the publication.
#  * @param key The name of the publication that a subscription is targeting.
#  * @forcpponly
#  * @param[in,out] err The error object to complete if there is an error.
#  * @endforcpponly
#  *
#  * @return A helics_input object, the object will not be valid and err will contain an error code if no input with the specified
#  * key exists.
#
proc helicsFederateGetSubscription*(l: HelicsLibrary, fed: HelicsFederate, key: string): HelicsInput =
  loadSym("helicsFederateGetSubscription")
  let err = l.helicsErrorInitialize()
  result = f(fed, key.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Clear all the update flags from a federates inputs.
#  *
#  * @param fed The value federate object for which to clear update flags.
#
proc helicsFederateClearUpdates*(l: HelicsLibrary, fed: HelicsFederate) =
  loadSym("helicsFederateClearUpdates")
  f(fed)

# *
#  * Register the publications via JSON publication string.
#  *
#  * @param fed The value federate object to use to register the publications.
#  * @param json The JSON publication string.
#  * @forcpponly
#  * @param[in,out] err The error object to complete if there is an error.
#  * @endforcpponly
#  *
#  * @details This would be the same JSON that would be used to publish data.
#
proc helicsFederateRegisterFromPublicationJSON*(l: HelicsLibrary, fed: HelicsFederate, json: string) =
  loadSym("helicsFederateRegisterFromPublicationJSON")
  let err = l.helicsErrorInitialize()
  f(fed, json.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Publish data contained in a JSON file or string.
#  *
#  * @param fed The value federate object through which to publish the data.
#  * @param json The publication file name or literal JSON data string.
#  * @forcpponly
#  * @param[in,out] err The error object to complete if there is an error.
#  * @endforcpponly
#
proc helicsFederatePublishJSON*(l: HelicsLibrary, fed: HelicsFederate, json: string) =
  loadSym("helicsFederatePublishJSON")
  let err = l.helicsErrorInitialize()
  f(fed, json.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * \defgroup publications Publication functions
#  * @details Functions for publishing data of various kinds.
#  * The data will get translated to the type specified when the publication was constructed automatically
#  * regardless of the function used to publish the data.
#  * @{
#
# *
#  * Check if a publication is valid.
#  *
#  * @param pub The publication to check.
#  *
#  * @return helics_true if the publication is a valid publication.
#
proc helicsPublicationIsValid*(l: HelicsLibrary, pub: HelicsPublication): HelicsBool =
  loadSym("helicsPublicationIsValid")
  result = f(pub)

# *
#  * Publish raw data from a char * and length.
#  *
#  * @param pub The publication to publish for.
#  * @param data A pointer to the raw data.
#  * @param inputDataLength The size in bytes of the data to publish.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsPublicationPublishRaw*(l: HelicsLibrary, pub: HelicsPublication, data: pointer, inputDataLength: int) =
  loadSym("helicsPublicationPublishRaw")
  let err = l.helicsErrorInitialize()
  f(pub, data, inputDataLength.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Publish a string.
#  *
#  * @param pub The publication to publish for.
#  * @param str The string to publish.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsPublicationPublishString*(l: HelicsLibrary, pub: HelicsPublication, str: string) =
  loadSym("helicsPublicationPublishString")
  let err = l.helicsErrorInitialize()
  f(pub, str.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Publish an integer value.
#  *
#  * @param pub The publication to publish for.
#  * @param val The numerical value to publish.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsPublicationPublishInteger*(l: HelicsLibrary, pub: HelicsPublication, val: int64) =
  loadSym("helicsPublicationPublishInteger")
  let err = l.helicsErrorInitialize()
  f(pub, val.int64, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Publish a Boolean Value.
#  *
#  * @param pub The publication to publish for.
#  * @param val The boolean value to publish.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsPublicationPublishBoolean*(l: HelicsLibrary, pub: HelicsPublication, val: HelicsBool) =
  loadSym("helicsPublicationPublishBoolean")
  let err = l.helicsErrorInitialize()
  f(pub, val, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Publish a double floating point value.
#  *
#  * @param pub The publication to publish for.
#  * @param val The numerical value to publish.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsPublicationPublishDouble*(l: HelicsLibrary, pub: HelicsPublication, val: float) =
  loadSym("helicsPublicationPublishDouble")
  let err = l.helicsErrorInitialize()
  f(pub, val.cdouble, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Publish a time value.
#  *
#  * @param pub The publication to publish for.
#  * @param val The numerical value to publish.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsPublicationPublishTime*(l: HelicsLibrary, pub: HelicsPublication, val: HelicsTime) =
  loadSym("helicsPublicationPublishTime")
  let err = l.helicsErrorInitialize()
  f(pub, val, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Publish a single character.
#  *
#  * @param pub The publication to publish for.
#  * @param val The numerical value to publish.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsPublicationPublishChar*(l: HelicsLibrary, pub: HelicsPublication, val: char) =
  loadSym("helicsPublicationPublishChar")
  let err = l.helicsErrorInitialize()
  f(pub, val.cchar, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Publish a complex value (or pair of values).
#  *
#  * @param pub The publication to publish for.
#  * @param real The real part of a complex number to publish.
#  * @param imag The imaginary part of a complex number to publish.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsPublicationPublishComplex*(l: HelicsLibrary, pub: HelicsPublication, real: float, imag: float) =
  loadSym("helicsPublicationPublishComplex")
  let err = l.helicsErrorInitialize()
  f(pub, real.cdouble, imag.cdouble, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Publish a vector of doubles.
#  *
#  * @param pub The publication to publish for.
#  * @param vectorInput A pointer to an array of double data.
#  * @forcpponly
#  * @param vectorLength The number of points to publish.
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsPublicationPublishVector*(l: HelicsLibrary, pub: HelicsPublication, vectorInput: ptr cdouble, vectorLength: int) =
  loadSym("helicsPublicationPublishVector")
  let err = l.helicsErrorInitialize()
  f(pub, vectorInput, vectorLength.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Publish a named point.
#  *
#  * @param pub The publication to publish for.
#  * @param str A string for the name to publish.
#  * @param val A double for the value to publish.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsPublicationPublishNamedPoint*(l: HelicsLibrary, pub: HelicsPublication, str: string, val: float) =
  loadSym("helicsPublicationPublishNamedPoint")
  let err = l.helicsErrorInitialize()
  f(pub, str.cstring, val.cdouble, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Add a named input to the list of targets a publication publishes to.
#  *
#  * @param pub The publication to add the target for.
#  * @param target The name of an input that the data should be sent to.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsPublicationAddTarget*(l: HelicsLibrary, pub: HelicsPublication, target: string) =
  loadSym("helicsPublicationAddTarget")
  let err = l.helicsErrorInitialize()
  f(pub, target.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Check if an input is valid.
#  *
#  * @param ipt The input to check.
#  *
#  * @return helics_true if the Input object represents a valid input.
#
proc helicsInputIsValid*(l: HelicsLibrary, ipt: HelicsInput): HelicsBool =
  loadSym("helicsInputIsValid")
  f(ipt)

# *
#  * Add a publication to the list of data that an input subscribes to.
#  *
#  * @param ipt The named input to modify.
#  * @param target The name of a publication that an input should subscribe to.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#
proc helicsInputAddTarget*(l: HelicsLibrary, ipt: HelicsInput, target: string) =
  loadSym("helicsInputAddTarget")
  let err = l.helicsErrorInitialize()
  f(ipt, target.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *@}
# *
#  * \defgroup getValue GetValue functions
#  * @details Data can be returned in a number of formats,  for instance if data is published as a double it can be returned as a string and
#  * vice versa,  not all translations make that much sense but they do work.
#  * @{
#
# *
#  * Get the size of the raw value for subscription.
#  *
#  * @return The size of the raw data/string in bytes.
#
proc helicsInputGetRawValueSize*(l: HelicsLibrary, ipt: HelicsInput): int =
  loadSym("helicsInputGetRawValueSize")
  result = f(ipt).int

# *
#  * Get the raw data for the latest value of a subscription.
#  *
#  * @param ipt The input to get the data for.
#  * @forcpponly
#  * @param[out] data The memory location of the data
#  * @param maxDatalen The maximum size of information that data can hold.
#  * @param[out] actualSize The actual length of data copied to data.
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @beginPythonOnly
#  * @return Raw string data.
#  * @endPythonOnly
#
proc helicsInputGetRawValue*(l: HelicsLibrary, ipt: HelicsInput, data: pointer, maxDatalen: int, actualSize: ptr cint) =
  loadSym("helicsInputGetRawValue")
  let err = l.helicsErrorInitialize()
  f(ipt, data, maxDatalen.cint, actualSize, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get the size of a value for subscription assuming return as a string.
#  *
#  * @return The size of the string.
#
proc helicsInputGetStringSize*(l: HelicsLibrary, ipt: HelicsInput): int =
  loadSym("helicsInputGetStringSize")
  result = f(ipt).int

# *
#  * Get a string value from a subscription.
#  *
#  * @param ipt The input to get the data for.
#  * @forcpponly
#  * @param[out] outputString Storage for copying a null terminated string.
#  * @param maxStringLen The maximum size of information that str can hold.
#  * @param[out] actualLength The actual length of the string.
#  * @param[in,out] err Error term for capturing errors.
#  * @endforcpponly
#  *
#  * @beginPythonOnly
#  * @return A string data
#  * @endPythonOnly
#
proc helicsInputGetString*(l: HelicsLibrary, ipt: HelicsInput, outputString: string, maxStringLen: int, actualLength: ptr cint) =
  loadSym("helicsInputGetString")
  let err = l.helicsErrorInitialize()
  f(ipt, outputString, maxStringLen.cint, actualLength, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get an integer value from a subscription.
#  *
#  * @param ipt The input to get the data for.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return An int64_t value with the current value of the input.
#
proc helicsInputGetInteger*(l: HelicsLibrary, ipt: HelicsInput): int64 =
  loadSym("helicsInputGetInteger")
  let err = l.helicsErrorInitialize()
  result = f(ipt, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get a boolean value from a subscription.
#  *
#  * @param ipt The input to get the data for.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return A boolean value of current input value.
#
proc helicsInputGetBoolean*(l: HelicsLibrary, ipt: HelicsInput): HelicsBool =
  loadSym("helicsInputGetBoolean")
  let err = l.helicsErrorInitialize()
  result = f(ipt, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get a double value from a subscription.
#  *
#  * @param ipt The input to get the data for.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return The double value of the input.
#
proc helicsInputGetDouble*(l: HelicsLibrary, ipt: HelicsInput): float =
  loadSym("helicsInputGetDouble")
  let err = l.helicsErrorInitialize()
  result = f(ipt, unsafeAddr err).float
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get a time value from a subscription.
#  *
#  * @param ipt The input to get the data for.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return The resulting time value.
#
proc helicsInputGetTime*(l: HelicsLibrary, ipt: HelicsInput): HelicsTime =
  loadSym("helicsInputGetTime")
  let err = l.helicsErrorInitialize()
  result = f(ipt, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get a single character value from an input.
#  *
#  * @param ipt The input to get the data for.
#  * @forcpponly
#  * @param[in,out] err A pointer to an error object for catching errors.
#  * @endforcpponly
#  *
#  * @return The resulting character value.
#  * @forcpponly
#  *         NAK (negative acknowledgment) symbol returned on error
#  * @endforcpponly
#
proc helicsInputGetChar*(l: HelicsLibrary, ipt: HelicsInput): char =
  loadSym("helicsInputGetChar")
  let err = l.helicsErrorInitialize()
  result = f(ipt, unsafeAddr err).char
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get a complex object from an input object.
#  *
#  * @param ipt The input to get the data for.
#  * @forcpponly
#  * @param[in,out] err A helics error object, if the object is not empty the function is bypassed otherwise it is filled in if there is an
#  * error.
#  * @endforcpponly
#  *
#  * @return A helics_complex structure with the value.
#
proc helicsInputGetComplexObject*(l: HelicsLibrary, ipt: HelicsInput): HelicsComplex =
  loadSym("helicsInputGetComplexObject")
  let err = l.helicsErrorInitialize()
  result = f(ipt, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get a pair of double forming a complex number from a subscriptions.
#  *
#  * @param ipt The input to get the data for.
#  * @forcpponly
#  * @param[out] real Memory location to place the real part of a value.
#  * @param[out] imag Memory location to place the imaginary part of a value.
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * On error the values will not be altered.
#  * @endforcpponly
#  *
#  * @beginPythonOnly
#  * @return a pair of floating point values that represent the real and imag values
#  * @endPythonOnly
#
proc helicsInputGetComplex*(l: HelicsLibrary, ipt: HelicsInput, real: ptr cdouble, imag: ptr cdouble) =
  loadSym("helicsInputGetComplex")
  let err = l.helicsErrorInitialize()
  f(ipt, real, imag, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get the size of a value for subscription assuming return as an array of doubles.
#  *
#  * @return The number of doubles in a returned vector.
#
proc helicsInputGetVectorSize*(l: HelicsLibrary, ipt: HelicsInput): int =
  loadSym("helicsInputGetVectorSize")
  f(ipt)

# *
#  * Get a vector from a subscription.
#  *
#  * @param ipt The input to get the result for.
#  * @forcpponly
#  * @param[out] data The location to store the data.
#  * @param maxlen The maximum size of the vector.
#  * @param[out] actualSize Location to place the actual length of the resulting vector.
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @beginPythonOnly
#  * @return a list of floating point values
#  * @endPythonOnly
#
# Declaration 'helicsInputGetVector' skipped
# Declaration 'ipt' skipped
# Declaration 'helicsInputGetVector' skipped
# Declaration 'ipt' skipped
# Declaration 'data' skipped
# Declaration 'maxlen' skipped
# Declaration 'actualSize' skipped
# Declaration 'err' skipped

# *
#  * Get a named point from a subscription.
#  *
#  * @param ipt The input to get the result for.
#  * @forcpponly
#  * @param[out] outputString Storage for copying a null terminated string.
#  * @param maxStringLen The maximum size of information that str can hold.
#  * @param[out] actualLength The actual length of the string
#  * @param[out] val The double value for the named point.
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#  *
#  * @beginPythonOnly
#  * @return a string and a double value for the named point
#  * @endPythonOnly
#
proc helicsInputGetNamedPoint*(l: HelicsLibrary, ipt: HelicsInput, outputString: string, maxStringLen: int, actualLength: ptr cint, val: ptr cdouble) =
  loadSym("helicsInputGetNamedPoint")
  let err = l.helicsErrorInitialize()
  f(ipt, outputString.cstring, maxStringLen.cint, actualLength, val, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *@}
# *
#  * \defgroup default_values Default Value functions
#  * @details These functions set the default value for a subscription. That is the value returned if nothing was published from elsewhere.
#  * @{
#
# *
#  * Set the default as a raw data array.
#  *
#  * @param ipt The input to set the default for.
#  * @param data A pointer to the raw data to use for the default.
#  * @forcpponly
#  * @param inputDataLength The size of the raw data.
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsInputSetDefaultRaw*(l: HelicsLibrary, ipt: HelicsInput, data: pointer, inputDataLength: int) =
  loadSym("helicsInputSetDefaultRaw")
  let err = l.helicsErrorInitialize()
  f(ipt, data, inputDataLength.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the default as a string.
#  *
#  * @param ipt The input to set the default for.
#  * @param str A pointer to the default string.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsInputSetDefaultString*(l: HelicsLibrary, ipt: HelicsInput, str: string) =
  loadSym("helicsInputSetDefaultString")
  let err = l.helicsErrorInitialize()
  f(ipt, str.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the default as an integer.
#  *
#  * @param ipt The input to set the default for.
#  * @param val The default integer.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsInputSetDefaultInteger*(l: HelicsLibrary, ipt: HelicsInput, val: int64) =
  loadSym("helicsInputSetDefaultInteger")
  let err = l.helicsErrorInitialize()
  f(ipt, val, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the default as a boolean.
#  *
#  * @param ipt The input to set the default for.
#  * @param val The default boolean value.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsInputSetDefaultBoolean*(l: HelicsLibrary, ipt: HelicsInput, val: HelicsBool) =
  loadSym("helicsInputSetDefaultBoolean")
  let err = l.helicsErrorInitialize()
  f(ipt, val, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the default as a time.
#  *
#  * @param ipt The input to set the default for.
#  * @param val The default time value.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsInputSetDefaultTime*(l: HelicsLibrary, ipt: HelicsInput, val: HelicsTime) =
  loadSym("helicsInputSetDefaultTime")
  let err = l.helicsErrorInitialize()
  f(ipt, val, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the default as a char.
#  *
#  * @param ipt The input to set the default for.
#  * @param val The default char value.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsInputSetDefaultChar*(l: HelicsLibrary, ipt: HelicsInput, val: char) =
  loadSym("helicsInputSetDefaultChar")
  let err = l.helicsErrorInitialize()
  f(ipt, val.cchar, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the default as a double.
#  *
#  * @param ipt The input to set the default for.
#  * @param val The default double value.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsInputSetDefaultDouble*(l: HelicsLibrary, ipt: HelicsInput, val: float) =
  loadSym("helicsInputSetDefaultDouble")
  let err = l.helicsErrorInitialize()
  f(ipt, val, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the default as a complex number.
#  *
#  * @param ipt The input to set the default for.
#  * @param real The default real value.
#  * @param imag The default imaginary value.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsInputSetDefaultComplex*(l: HelicsLibrary, ipt: HelicsInput, real: float, imag: float) =
  loadSym("helicsInputSetDefaultComplex")
  let err = l.helicsErrorInitialize()
  f(ipt, real.cdouble, imag.cdouble, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the default as a vector of doubles.
#  *
#  * @param ipt The input to set the default for.
#  * @param vectorInput A pointer to an array of double data.
#  * @param vectorLength The number of points to publish.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsInputSetDefaultVector*(l: HelicsLibrary, ipt: HelicsInput, vectorInput: ptr cdouble, vectorLength: int) =
  loadSym("helicsInputSetDefaultVector")
  let err = l.helicsErrorInitialize()
  f(ipt, vectorInput, vectorLength.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the default as a NamedPoint.
#  *
#  * @param ipt The input to set the default for.
#  * @param str A pointer to a string representing the name.
#  * @param val A double value for the value of the named point.
#  * @forcpponly
#  * @param[in,out] err An error object that will contain an error code and string if any error occurred during the execution of the function.
#  * @endforcpponly
#
proc helicsInputSetDefaultNamedPoint*(l: HelicsLibrary, ipt: HelicsInput, str: string, val: float) =
  loadSym("helicsInputSetDefaultNamedPoint")
  let err = l.helicsErrorInitialize()
  f(ipt, str.cstring, val.cdouble, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *@}
# *
#  * \defgroup Information retrieval
#  * @{
#
# *
#  * Get the type of an input.
#  *
#  * @param ipt The input to query.
#  *
#  * @return A void enumeration, helics_ok if everything worked.
#
proc helicsInputGetType*(l: HelicsLibrary, ipt: HelicsInput): string =
  loadSym("helicsInputGetType")
  result = $(f(ipt))

# *
#  * Get the type the publisher to an input is sending.
#  *
#  * @param ipt The input to query.
#  *
#  * @return A const char * with the type name.
#
proc helicsInputGetPublicationType*(l: HelicsLibrary, ipt: HelicsInput): string =
  loadSym("helicsInputGetPublicationType")
  result = $(f(ipt))

# *
#  * Get the type of a publication.
#  *
#  * @param pub The publication to query.
#  *
#  * @return A void enumeration, helics_ok if everything worked.
#
proc helicsPublicationGetType*(l: HelicsLibrary, pub: HelicsPublication): string =
  loadSym("helicsPublicationGetType")
  result = $(f(pub))

# *
#  * Get the key of an input.
#  *
#  * @param ipt The input to query.
#  *
#  * @return A void enumeration, helics_ok if everything worked.
#
proc helicsInputGetKey*(l: HelicsLibrary, ipt: HelicsInput): string =
  loadSym("helicsInputGetKey")
  result = $(f(ipt))

# *
#  * Get the key of a subscription.
#  *
#  * @return A const char with the subscription key.
#
proc helicsSubscriptionGetKey*(l: HelicsLibrary, ipt: HelicsInput): string =
  loadSym("helicsSubscriptionGetKey")
  result = $(f(ipt))

# *
#  * Get the key of a publication.
#  *
#  * @details This will be the global key used to identify the publication to the federation.
#  *
#  * @param pub The publication to query.
#  *
#  * @return A void enumeration, helics_ok if everything worked.
#
proc helicsPublicationGetKey*(l: HelicsLibrary, pub: HelicsPublication): string =
  loadSym("helicsPublicationGetKey")
  result = $(f(pub))

# *
#  * Get the units of an input.
#  *
#  * @param ipt The input to query.
#  *
#  * @return A void enumeration, helics_ok if everything worked.
#
proc helicsInputGetUnits*(l: HelicsLibrary, ipt: HelicsInput): string =
  loadSym("helicsInputGetUnits")
  result = $(f(ipt))

# *
#  * Get the units of the publication that an input is linked to.
#  *
#  * @param ipt The input to query.
#  *
#  * @return A void enumeration, helics_ok if everything worked.
#
proc helicsInputGetInjectionUnits*(l: HelicsLibrary, ipt: HelicsInput): string =
  loadSym("helicsInputGetInjectionUnits")
  result = $(f(ipt))

# *
#  * Get the units of an input.
#  *
#  * @details The same as helicsInputGetUnits.
#  *
#  * @param ipt The input to query.
#  *
#  * @return A void enumeration, helics_ok if everything worked.
#
proc helicsInputGetExtractionUnits*(l: HelicsLibrary, ipt: HelicsInput): string =
  loadSym("helicsInputGetExtractionUnits")
  result = $(f(ipt))

# *
#  * Get the units of a publication.
#  *
#  * @param pub The publication to query.
#  *
#  * @return A void enumeration, helics_ok if everything worked.
#
proc helicsPublicationGetUnits*(l: HelicsLibrary, pub: HelicsPublication): string =
  loadSym("helicsPublicationGetUnits")
  result = $(f(pub))

# *
#  * Get the data in the info field of an input.
#  *
#  * @param inp The input to query.
#  *
#  * @return A string with the info field string.
#
proc helicsInputGetInfo*(l: HelicsLibrary, inp: HelicsInput): string =
  loadSym("helicsInputGetInfo")
  result = $(f(inp))

# *
#  * Set the data in the info field for an input.
#  *
#  * @param inp The input to query.
#  * @param info The string to set.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsInputSetInfo*(l: HelicsLibrary, inp: HelicsInput, info: string) =
  loadSym("helicsInputSetInfo")
  let err = l.helicsErrorInitialize()
  f(inp, info, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get the data in the info field of an publication.
#  *
#  * @param pub The publication to query.
#  *
#  * @return A string with the info field string.
#
proc helicsPublicationGetInfo*(l: HelicsLibrary, pub: HelicsPublication): string =
  loadSym("helicsPublicationGetInfo")
  result = $(f(pub))

# *
#  * Set the data in the info field for a publication.
#  *
#  * @param pub The publication to set the info field for.
#  * @param info The string to set.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsPublicationSetInfo*(l: HelicsLibrary, pub: HelicsPublication, info: string) =
  loadSym("helicsPublicationSetInfo")
  let err = l.helicsErrorInitialize()
  f(pub, info.cstring, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get the current value of an input handle option
#  *
#  * @param inp The input to query.
#  * @param option Integer representation of the option in question see /ref helics_handle_options.
#  *
#  * @return An integer value with the current value of the given option.
#
proc helicsInputGetOption*(l: HelicsLibrary, inp: HelicsInput, option: int): int =
  loadSym("helicsInputGetOption")
  result = f(inp, option.cint).int

# *
#  * Set an option on an input
#  *
#  * @param inp The input to query.
#  * @param option The option to set for the input /ref helics_handle_options.
#  * @param value The value to set the option to.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsInputSetOption*(l: HelicsLibrary, inp: HelicsInput, option: int, value: int) =
  loadSym("helicsInputSetOption")
  let err = l.helicsErrorInitialize()
  f(inp, option.cint, value.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Get the value of an option for a publication
#  *
#  * @param pub The publication to query.
#  * @param option The value to query see /ref helics_handle_options.
#  *
#  * @return A string with the info field string.
#
proc helicsPublicationGetOption*(l: HelicsLibrary, pub: HelicsPublication, option: int): int =
  loadSym("helicsPublicationGetOption")
  result = f(pub, option.cint).int

# *
#  * Set the value of an option for a publication
#  *
#  * @param pub The publication to query.
#  * @param option Integer code for the option to set /ref helics_handle_options.
#  * @param val The value to set the option to.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsPublicationSetOption*(l: HelicsLibrary, pub: HelicsPublication, option: int, val: int) =
  loadSym("helicsPublicationSetOption")
  let err = l.helicsErrorInitialize()
  f(pub, option.cint, val.cint, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the minimum change detection tolerance.
#  *
#  * @param pub The publication to modify.
#  * @param tolerance The tolerance level for publication, values changing less than this value will not be published.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsPublicationSetMinimumChange*(l: HelicsLibrary, pub: HelicsPublication, tolerance: float) =
  loadSym("helicsPublicationSetMinimumChange")
  let err = l.helicsErrorInitialize()
  f(pub, tolerance.cdouble, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *
#  * Set the minimum change detection tolerance.
#  *
#  * @param inp The input to modify.
#  * @param tolerance The tolerance level for registering an update, values changing less than this value will not show asbeing updated.
#  * @forcpponly
#  * @param[in,out] err An error object to fill out in case of an error.
#  * @endforcpponly
#
proc helicsInputSetMinimumChange*(l: HelicsLibrary, inp: HelicsInput, tolerance: float) =
  loadSym("helicsInputSetMinimumChange")
  let err = l.helicsErrorInitialize()
  f(inp, tolerance.cdouble, unsafeAddr err)
  if err.error_code != 0:
    raise newException(HelicsException, $(err.message))

# *@}
# *
#  * Check if a particular subscription was updated.
#  *
#  * @return helics_true if it has been updated since the last value retrieval.
#
proc helicsInputIsUpdated*(l: HelicsLibrary, ipt: HelicsInput): HelicsBool =
  loadSym("helicsInputIsUpdated")
  result = f(ipt)

# *
#  * Get the last time a subscription was updated.
#
proc helicsInputLastUpdateTime*(l: HelicsLibrary, ipt: HelicsInput): HelicsTime =
  loadSym("helicsInputLastUpdateTime")
  result = f(ipt)

# *
#  * Clear the updated flag from an input.
#
proc helicsInputClearUpdate*(l: HelicsLibrary, ipt: HelicsInput) =
  loadSym("helicsInputClearUpdate")
  f(ipt)

# *
#  * Get the number of publications in a federate.
#  *
#  * @return (-1) if fed was not a valid federate otherwise returns the number of publications.
#
proc helicsFederateGetPublicationCount*(l: HelicsLibrary, fed: HelicsFederate): int =
  loadSym("helicsFederateGetPublicationCount")
  result = f(fed).int

# *
#  * Get the number of subscriptions in a federate.
#  *
#  * @return (-1) if fed was not a valid federate otherwise returns the number of subscriptions.
#
proc helicsFederateGetInputCount*(l: HelicsLibrary, fed: HelicsFederate): int =
  loadSym("helicsFederateGetInputCount")
  result = f(fed).int


proc loadHelicsLibrary(path: string): HelicsLibrary =
  result = HelicsLibrary()
  result.lib = loadLib(path)
  if result.lib == nil:
    raise newException(ValueError, "couldn't load library: " & path)
