import os, strutils, strformat

const helics_install_path = getEnv("HELICS_INSTALL")

static:
  putEnv("HELICS_INSTALL", helics_install_path)

when defined(linux):
  block:
    {.passL: """-Wl,-rpath,'""" & helics_install_path & """/lib/'""".}
    {.passL: """-Wl,-rpath,'$ORIGIN'""".}
    {.passL: """-Wl,-rpath,'$ORIGIN/lib/'""".}
    {.passL: """-Wl,-rpath,'$ORIGIN/../lib/'""".}
    {.passL: """-Wl,-rpath,'.'""".}
    {.passL: """-Wl,-rpath,'/usr/lib/'""".}
    {.passL: """-Wl,-rpath,'/usr/local/lib/'""".}

when defined(macosx):
  block:
    {.passL: """-Wl,-rpath,'""" & helics_install_path & """/lib/'""".}
    {.passL: """-Wl,-rpath,'@loader_path'""".}
    {.passL: """-Wl,-rpath,'@loader_path/lib/'""".}
    {.passL: """-Wl,-rpath,'@loader_path/../lib/'""".}
    {.passL: """-Wl,-rpath,'@executable_path'""".}
    {.passL: """-Wl,-rpath,'@executable_path/../lib/'""".}
    {.passL: """-Wl,-rpath,'.'""".}
    {.passL: """-Wl,-rpath,'/usr/lib/'""".}
    {.passL: """-Wl,-rpath,'/usr/local/lib/'""".}

import nimterop/[cimport, build, paths]

const
  baseDir = currentSourcePath.parentDir()/"build"

  srcDir = baseDir/"helics"

const version = "2.5.0"

when defined(Windows):
  const tarfile = &"Helics-shared-{version}-win64"
elif defined(macosx):
  const tarfile = &"Helics-shared-{version}-macOS-x86_64"
else:
  const tarfile = &"Helics-shared-{version}-Linux-x86_64"

const dlUrl = &"https://github.com/GMLC-TDC/HELICS/releases/download/v{version}/{tarfile}.tar.gz"
const folder = tarfile.replace("-shared", "")


proc camel2snake*(s: string): string {.noSideEffect, procvar.} =
  ## CanBeFun => can_be_fun
  result = newStringOfCap(s.len)
  for i in 0..<len(s):
    if s[i] in {'A'..'Z'}:
      if i > 0:
        result.add('_')
      result.add(chr(ord(s[i]) + (ord('a') - ord('A'))))
    else:
      result.add(s[i])

static:
  # cDebug()
  # cDisableCaching()

  downloadUrl(
    dlUrl,
    outDir = srcDir,
  )

cPlugin:
  import strutils

  proc onSymbol*(sym: var Symbol) {.exportc, dynlib.} =
    # Remove prefixes or suffixes from procs
    if sym.kind == nskType and sym.name.startsWith("helics_"):
      var substring = sym.name.split("_")
      var r = ""
      for s in substring:
        r.add(s.capitalizeAscii())
      sym.name = r
    elif sym.kind == nskEnumField and sym.name.startsWith("helics"):
      sym.name = sym.name.toUpper()
    elif sym.kind == nskConst and sym.name.startsWith("helics"):
      sym.name = sym.name.toUpper()

when defined(Windows):
  const dynlibFile = "libhelicsSharedLib.dll"
elif defined(posix):
  when defined(linux):
    const dynlibFile = &"libhelicsSharedLib.so(.{version})"
  elif defined(osx):
    const dynlibFile = &"libhelicsSharedLib(.{version}).dylib"
  else:
    static: doAssert false
else:
  static: doAssert false

cImport(srcDir/folder/"/include/helics/chelics.h", recurse = true, dynlib = "dynlibFile", flags="-f:ast2")
