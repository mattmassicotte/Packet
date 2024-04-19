<div align="center">

[![Build Status][build status badge]][build status]
[![Platforms][platforms badge]][platforms]
[![Documentation][documentation badge]][documentation]

</div>

# Packet

A collection of utilities for working with `Data` and `AsyncSequence`.

Lots of stuff here is Foundation-specific. But, the idea is to compliment [async-algorithms](https://github.com/apple/swift-async-algorithms), not overlap. 

## Integration

```swift
dependencies: [
    .package(url: "https://github.com/mattmassicotte/Packet", branch: "main")
]
```

## Usage

`FileHandle` support:

```swift
let fileHandle = FileHandle(...)

for await data in fileHandle.chunks {
    // use Data value here
}
```

`URLSession` support. This offers a [considerable performance benefit](https://falsevictories.com/devdiary/#20241804).

```swift
let stream = URLSession.shared.chunks(for: url)
for try await data in stream {
    // use Data value here
}
```

Sometimes, to make things work with an existing API, you need to un-chunk a sequence. `AsyncByteSequence` converts a sequence of `Data` into a sequence of `UInt8`. This is inherently less-efficient, but can be a lot less work than changing the consumer.

```swift
let bytes = AsyncByteSequence(dataSequence)

for try await byte in bytes {
    // one byte at a time
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
