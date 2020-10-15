# helics.nim

A nim interface to HELICS.

## Install

Use [`nimble`](https://github.com/nim-lang/nimble):

```bash
nimble install https://github.com/GMLC-TDC/helics.nim#head
```

You can then use it as shown below:

```nim
import helics

let h = loadHelicsLibrary("libhelicsSharedLib.2.6.0.(dylib|so|dll)")
echo h.helicsGetVersion()
```

You can use the `HELICS_INSTALL` environment variable to let the nim library know where to import the HELICS `libhelicsSharedLib` library from.

You can also search for multiple versions:

```nim
let h = loadHelicsLibrary("libhelicsSharedLib(.2.5.0|.2.6.0).(dylib|so|dll)")
```

See [the nim documentation for `loadLibPattern`](https://nim-lang.org/1.2.0/dynlib.html#loadLibPattern%2Cstring) for more information.

## Release

helics.nim is distributed under the terms of the BSD-3 clause license.
All new contributions must be made under this license. [LICENSE](LICENSE)

SPDX-License-Identifier: BSD-3-Clause
