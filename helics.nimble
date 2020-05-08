# Package

version       = "0.1.0"
author        = "Dheepak Krishnamurthy"
description   = "Nim binding for HELICS"
license       = "MIT"
skipDirs      = @["c2nim"]
srcDir        = "src"

# Dependencies

requires "nim >= 0.19.0"

import os, strutils

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

proc process(headerPath: string) =
  let content = readFile(headerPath)
  writeFile(headerPath, content.replace("HELICS_DEPRECATED_EXPORT ", "").replace("HELICS_EXPORT ", ""))
  let (dir, headerFile, ext) = splitFile(headerPath)
  let headerFileSanitized = headerFile.replace('-', '_').camel2snake()
  let outPath = "src/private" / headerFileSanitized.addFileExt("nim")
  exec("c2nim --dynlib:helicsSharedLib --cdecl --header:'\"" & headerFile.addFileExt(".h") & "\"' -o:" & outPath & " " & headerPath)

proc processAll() =
  exec("mkdir -p helics/private")
  process("c2nim/include/helics/shared_api_library/api-data.h")
  process("c2nim/include/helics/shared_api_library/helics.h")
  process("c2nim/include/helics/shared_api_library/helicsCallbacks.h")
  process("c2nim/include/helics/shared_api_library/MessageFederate.h")
  process("c2nim/include/helics/shared_api_library/ValueFederate.h")
  process("c2nim/include/helics/shared_api_library/MessageFilters.h")
  process("c2nim/include/helics/helics_enums.h")

task download, "get releases from precompiled binaries":
  exec("bbd download --package HELICS --install c2nim")
  exec("chmod -R +w c2nim")

task headers, "generate bindings from headers":
  processAll()
