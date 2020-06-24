import ../helics

when isMainModule:
  import unittest

  suite "test get version":

    let l = loadHelicsLibrary("libhelicsSharedLib(|.2.5.2|.2.5.1|.2.5.0).dylib")
    test "version":
      check:
        l.helicsGetVersion() == "2.5.2 (2020-06-14)"
