# Package

version       = "0.1.0"
author        = "Dheepak Krishnamurthy"
description   = "Nim binding for HELICS"
license       = "MIT"
skipDirs      = @["c2nim"]

# Dependencies

requires "nim >= 0.19.0"

import ospaths, strutils

proc getReleases() =
  # TODO: get release number
  # TODO: get release based on platform
  exec("rm -rf c2nim HELICS.*.tar.gz")
  exec("mkdir -p c2nim")

  var filename = ""

  exec("curl -LO https://github.com/JuliaBinaryWrappers/HELICS_jll.jl/releases/download/HELICS-v2.4.2%2B0/HELICS.v2.4.2.x86_64-apple-darwin14-cxx11.tar.gz")
  filename = "HELICS.v2.4.2.x86_64-apple-darwin14-cxx11.tar.gz"
  exec("tar -xvf " & filename & " -C c2nim")
  exec("rm " & filename)

  exec("curl -LO https://github.com/JuliaBinaryWrappers/ZeroMQ_jll.jl/releases/download/ZeroMQ-v4.3.2%2B2/ZeroMQ.v4.3.2.x86_64-apple-darwin14-cxx11.tar.gz")
  filename = "ZeroMQ.v4.3.2.x86_64-apple-darwin14-cxx11.tar.gz"
  exec("tar -xvf " & filename & " -C c2nim")
  exec("rm " & filename)

  exec("chmod -R +w c2nim")

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
  getReleases()

task headers, "generate bindings from headers":
  processAll()
