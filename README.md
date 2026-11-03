# swift-smpte-st-12

![Development Status](https://img.shields.io/badge/status-active--development-blue.svg)

Swift implementation of SMPTE ST 12-1 timecode, with drop-frame counting at 29.97 and 59.94.

## Overview

Time addresses from frame counts and back, at any whole nominal rate, with drop-frame counting where ST 12 defines it.

```swift
import SMPTE_ST_12

try SMPTE_ST_12.Timecode(frame: 1800, rate: .thirty, counting: .drop).description  // "00:01:00;02"
```

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/swift-standards/swift-smpte-st-12.git", branch: "main")
]
```

```swift
.target(
    name: "App",
    dependencies: [
        .product(name: "SMPTE ST 12", package: "swift-smpte-st-12")
    ]
)
```

## License

This package is licensed under the Apache License 2.0. See [LICENSE.md](LICENSE.md) for details.
