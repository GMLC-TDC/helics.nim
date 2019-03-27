# Package

version       = "0.1.0"
author        = "Dheepak Krishnamurthy"
description   = "Nim binding for HELICS"
license       = "MIT"
skipDirs      = @["c2nim"]

# Dependencies

requires "nim >= 0.19.0"

import ospaths, strutils

proc process(headerPath: string) =
  let content = readFile(headerPath)
  writeFile(headerPath, content.replace("HELICS_EXPORT ", ""))
  let (dir, headerFile, ext) = splitFile(headerPath)
  let outPath = "helics" / headerFile.addFileExt("nim")
  exec("c2nim " & headerPath & " --cdecl -o:" & outPath)

proc processAll() =
  exec("mkdir -p helics")
  process("c2nim/helics/shared_api_library/api-data.h")
  process("c2nim/helics/shared_api_library/helics.h")
  process("c2nim/helics/shared_api_library/helicsCallbacks.h")
  process("c2nim/helics/shared_api_library/MessageFederate.h")
  process("c2nim/helics/shared_api_library/ValueFederate.h")
  process("c2nim/helics/shared_api_library/MessageFilters.h")
  process("c2nim/helics/helics_enums.h")

task headers, "generate bindings from headers":
  processAll()

