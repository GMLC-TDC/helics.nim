import os

const helics_install_path = getEnv("HELICS_INSTALL")

static:
  putEnv("HELICS_INSTALL", helics_install_path)

when defined(linux) or defined(macosx):
  block:
    {.passL: """-Wl,-rpath,'""" & helics_install_path & """/lib/'""".}
    {.passL: """-Wl,-rpath,'$ORIGIN""" & helics_install_path & """/lib/'""".}
    {.passL: """-Wl,-rpath,'$ORIGIN'""".}

when defined(windows):
  const helicsSharedLib* = "helicsSharedLib.dll"
elif defined(macosx):
  const helicsSharedLib* = "libhelicsSharedLib.dylib"
else:
  const helicsSharedLib* = "libhelicsSharedLib.so"

include private/helics
