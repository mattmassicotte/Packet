import Foundation

public typealias AsyncDataChunks = AsyncStream<Data>

extension FileHandle {
	/// The file’s contents, as an asynchronous sequence of data chunks.
	public var chunks: AsyncDataChunks {
		let (stream, continuation) = AsyncDataChunks.makeStream()

		readabilityHandler = { handle in
			let data = handle.availableData

			if data.isEmpty {
				handle.readabilityHandler = nil
				continuation.finish()
				return
			}

			continuation.yield(data)
		}

		return stream
	}
}
