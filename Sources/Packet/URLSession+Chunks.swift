import Foundation

public typealias AsyncThrowingDataChunks = AsyncThrowingStream<Data, Error>

extension URLSession {
    /// Retrieves the contents of a url and delivers the data asynchronously as `Data` chunks.
    /// - Parameter url: The URL to retrieve.
    /// - Returns: An asychronously-delivered ``AsyncThrowingDataChunks`` sequence to iterate over.
    ///
    /// Use this method to when you want to process the chunks while the transfer is underway. You can use
    /// a `for-try-await-in` loop to handle each chunk.
    public func chunks(for url: URL) -> AsyncThrowingDataChunks {
        AsyncThrowingDataChunks { continuation in
            let dataTask = dataTask(with: url)
            dataTask.delegate = DataChunksTaskDelegate(withContinuation: continuation)
            
            dataTask.resume()
        }
    }
}

private final class DataChunksTaskDelegate: NSObject {
    let continuation: AsyncThrowingDataChunks.Continuation
    
    init(withContinuation continuation: AsyncThrowingDataChunks.Continuation) {
        self.continuation = continuation
    }
}

extension DataChunksTaskDelegate: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession,
                           dataTask: URLSessionDataTask,
                           didReceive data: Data) {
        continuation.yield(data)
    }
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didCompleteWithError error: Error?) {
        if let error {
            continuation.finish(throwing: error)
        } else {
            continuation.finish()
        }
    }
}
