<div align="center">

[![Build Status][build status badge]][build status]
[![Platforms][platforms badge]][platforms]
[![Documentation][documentation badge]][documentation]

</div>

# Packet

A collection of utilities for working with `Data` and `AsyncSequence`.

## Integration

```swift
dependencies: [
    .package(url: "https://github.com/mattmassicotte/Packet", branch: "main")
]
```

## Usage

```swift
let fileHandle = FileHandle(...)

for await data in fileHandle.chunks {
    // read Data objects instead of one byte at a time
}
```

## Contributing and Collaboration

I'd love to hear from you! Get in touch via [mastodon](https://mastodon.social/@mattiem), an issue, or a pull request.

I prefer collaboration, and would love to find ways to work together if you have a similar project.

I prefer indentation with tabs for improved accessibility. But, I'd rather you use the system you want and make a PR than hesitate because of whitespace.

By participating in this project you agree to abide by the [Contributor Code of Conduct](CODE_OF_CONDUCT.md).

[build status]: https://github.com/mattmassicotte/Packet/actions
[build status badge]: https://github.com/mattmassicotte/Packet/workflows/CI/badge.svg
[platforms]: https://swiftpackageindex.com/mattmassicotte/Packet
[platforms badge]: https://img.shields.io/endpoint?url=https%3A%2F%2Fswiftpackageindex.com%2Fapi%2Fpackages%2Fmattmassicotte%2FPacket%2Fbadge%3Ftype%3Dplatforms
[documentation]: https://swiftpackageindex.com/mattmassicotte/Packet/main/documentation
[documentation badge]: https://img.shields.io/badge/Documentation-DocC-blue
