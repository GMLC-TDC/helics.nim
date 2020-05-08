import os

const helics_install_path = getEnv("HELICS_INSTALL")

static:
  putEnv("HELICS_INSTALL", helics_install_path)

when defined(linux):
  block:
    {.passL: """-Wl,-rpath,'""" & helics_install_path & """/lib/'""".}
    {.passL: """-Wl,-rpath,'$ORIGIN""" & helics_install_path & """/lib/'""".}
    {.passL: """-Wl,-rpath,'$ORIGIN'""".}

when defined(macosx):
  block:
    {.passL: """-Wl,-rpath,'""" & helics_install_path & """/lib/'""".}
    {.passL: """-Wl,-rpath,'@loader_path""" & helics_install_path & """/lib/'""".}
    {.passL: """-Wl,-rpath,'@loader_path'""".}
    {.passL: """-Wl,-rpath,'@executable_path""" & helics_install_path & """/lib/'""".}
    {.passL: """-Wl,-rpath,'@executable_path'""".}

when defined(windows):
  const helicsSharedLib* = "helicsSharedLib.dll"
elif defined(macosx):
  const helicsSharedLib* = "libhelicsSharedLib.dylib"
else:
  const helicsSharedLib* = "libhelicsSharedLib.so"

include private/helics
