import ../helics/private/helics

when isMainModule:
  import unittest

  suite "test get version":

    test "version":
      check:
        helicsGetVersion() == "2.4.2 (2020-03-27)"
