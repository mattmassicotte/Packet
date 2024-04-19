import Foundation

public typealias AsyncThrowingDataChunks = AsyncThrowingStream<Data, any Error>

extension URLSession {
    /// Retrieves the contents of a url and delivers the data asynchronously as `Data` chunks.
    /// - Parameter url: The URL to retrieve.
    /// - Parameter delegate: A delegate that receives life cycle and authentication challenge callbacks as the transfer progresses.
    /// - Returns: An asychronously-delivered ``AsyncThrowingDataChunks`` sequence to iterate over.
    ///
    /// Use this method to when you want to process the chunks while the transfer is underway. You can use
    /// a `for-await-in` loop to handle each chunk like this:
    /// ```swift
    /// guard let url = URL(string: "https://www.example.com") else {
    ///     return
    /// }
    ///
    /// do {
    ///     // Read each chunk of the data as it becomes available
    ///     for try await chunk in URLSession.chunks(for: url) {
    ///         // Do something with chunk
    ///     }
    /// } catch {
    ///     print("Error \(error)")
    /// }
    /// ```
    @available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
    public func chunks(for url: URL, 
                       delegate: (any URLSessionTaskDelegate)? = nil) -> AsyncThrowingDataChunks {
        AsyncThrowingDataChunks { continuation in
            let dataTask = dataTask(with: url)
            dataTask.delegate = DataChunksTaskDelegate(withContinuation: continuation, delegate: delegate)
            
            
            dataTask.resume()
        }
    }
}

private final class DataChunksTaskDelegate: NSObject {
    let continuation: AsyncThrowingDataChunks.Continuation
    let delegate: (any URLSessionTaskDelegate)?
    
    init(withContinuation continuation: AsyncThrowingDataChunks.Continuation,
         delegate: (any URLSessionTaskDelegate)?) {
        self.continuation = continuation
        self.delegate = delegate
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
    
    public func urlSession(_ session: URLSession, 
                           task: URLSessionTask,
                           willPerformHTTPRedirection response: HTTPURLResponse,
                           newRequest request: URLRequest,
                           completionHandler: @escaping @Sendable (URLRequest?) -> Void) {
        delegate?.urlSession?(session, task: task, willPerformHTTPRedirection: response, newRequest: request, completionHandler: completionHandler)
    }
    
    public func urlSession(_ session: URLSession, 
                           task: URLSessionTask,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        delegate?.urlSession?(session, task: task, didReceive: challenge, completionHandler: completionHandler)
    }
    
    public func urlSession(_ session: URLSession, 
                           taskIsWaitingForConnectivity task: URLSessionTask) {
        delegate?.urlSession?(session, taskIsWaitingForConnectivity: task)
    }
}
