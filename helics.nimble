# Package

version       = "0.1.0"
author        = "Dheepak Krishnamurthy"
description   = "Nim binding for HELICS"
license       = "MIT"
skipDirs      = @["c2nim"]

# Dependencies

requires "nim >= 0.19.0"

import os, strutils

proc process(headerPath: string) =
  let content = readFile(headerPath)
  writeFile(headerPath, content.replace("HELICS_EXPORT ", ""))
  let (dir, headerFile, ext) = splitFile(headerPath)
  let headerFileSanitized = headerFile.replace('-', '_')
  let outPath = "helics/private" / headerFileSanitized.addFileExt("nim")
  exec("c2nim " & headerPath & " --header:'\"" & headerFile.addFileExt(".h") & "\"' --cdecl -o:" & outPath)

proc processAll() =
  exec("mkdir -p helics")
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
