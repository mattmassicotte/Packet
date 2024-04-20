import Foundation

public typealias AsyncThrowingDataChunks = AsyncThrowingStream<Data, any Error>
typealias ResponseContinuation = CheckedContinuation<(AsyncThrowingDataChunks, URLResponse), Error>

extension URLSession {
    /// Retrieves the contents of a url and delivers the data asynchronously as `Data` chunks.
    /// - Parameter url: The URL to retrieve.
    /// - Parameter delegate: A delegate that receives life cycle and authentication challenge callbacks as the transfer progresses.
    /// - Returns: An asychronously-delivered tuple containing an ``AsyncThrowingDataChunks`` sequence to iterate over
    /// and the ``URLResponse`` from the server.
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
    ///     let (chunks, response) = try await URLSession.shared.chunks(for: url)
    ///     for try await chunk in chunks {
    ///         // Do something with chunk
    ///     }
    /// } catch {
    ///     print("Error \(error)")
    /// }
    /// ```
    @available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
    public func chunks(for url: URL,
                       delegate: (any URLSessionTaskDelegate)? = nil) async throws -> (AsyncThrowingDataChunks, URLResponse) {
        return try await chunks(for: URLRequest(url: url), delegate: delegate)
    }
    
    /// Retrieves the contents of a URL based on the specified URL request and delivers an asynchronous
    /// sequence of `Data` chunks.
    /// - Parameter request: A URL request object that provides request-specific information
    /// such as the URL, cache policy, request type, and body data or body stream.
    /// - Parameter delegate: A delegate that receives life cycle and authentication challenge callbacks as the transfer progresses.
    /// - Returns: An asynchronously delivered tuple of ``AsyncThrowingDataChunks`` sequence to iterate over
    ///  and the ``URLResponse`` from the server.
    ///
    /// Use this method when you want to process the bytes while the transfer is underway. You can use
    /// a `for-await-in` loop to handle each chunk like this:
    /// ```swift
    /// guard let url = URL(string: "https://www.example.com") else {
    ///     return
    /// }
    ///
    /// let request = URLRequest(url)
    /// do {
    ///     // Read each chunk of the data as it becomes available
    ///     let (chunks, response) = try await URLSession.shared.chunks(for: request)
    ///     for try await chunk in chunk {
    ///         // Do something with chunk
    ///     }
    /// } catch {
    ///     print("Error: \(error)")
    /// }
    /// ```
    @available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
    public func chunks(for request: URLRequest,
                       delegate: (any URLSessionTaskDelegate)? = nil) async throws -> (AsyncThrowingDataChunks, URLResponse) {
        try await withCheckedThrowingContinuation { responseContinuation in
            let chunksDelegate = DataChunksTaskDelegate(delegate: delegate)
            chunksDelegate.responseContinuation = responseContinuation
            
            chunksDelegate.stream = AsyncThrowingDataChunks { streamContinuation in
                chunksDelegate.continuation = streamContinuation
                let dataTask = dataTask(with: request)
                dataTask.delegate = chunksDelegate
                dataTask.resume()
            }
        }
    }
    
    @available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
    func chunks(for url: URL,
                delegate: (any URLSessionTaskDelegate)? = nil) -> AsyncThrowingDataChunks {
        return chunks(for: URLRequest(url: url), delegate: delegate)
    }
    
    @available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
    func chunks(for request: URLRequest,
                delegate: (any URLSessionTaskDelegate)? = nil) -> AsyncThrowingDataChunks {
        AsyncThrowingDataChunks { continuation in
            let dataTask = dataTask(with: request)
            dataTask.delegate = DataChunksTaskDelegate(withContinuation: continuation,
                                                       delegate: delegate)
            dataTask.resume()
        }
    }
}

private final class DataChunksTaskDelegate: NSObject {
    var continuation: AsyncThrowingDataChunks.Continuation?
    let delegate: (any URLSessionTaskDelegate)?
    
    var stream: AsyncThrowingDataChunks?
    var responseContinuation: ResponseContinuation?
    
    init(delegate: (any URLSessionTaskDelegate)?) {
        self.delegate = delegate
    }
    
    init(withContinuation continuation: AsyncThrowingDataChunks.Continuation,
         delegate: (any URLSessionTaskDelegate)?) {
        self.continuation = continuation
        self.delegate = delegate
    }
    
    init(withContinuation continuation: AsyncThrowingDataChunks.Continuation,
         responseContinuation: ResponseContinuation,
         stream: AsyncThrowingDataChunks,
         delegate: (any URLSessionTaskDelegate)?) {
        self.continuation = continuation
        self.responseContinuation = responseContinuation
        self.stream = stream
        self.delegate = delegate
    }
}

extension DataChunksTaskDelegate: URLSessionDataDelegate {
    public func urlSession(_ session: URLSession,
                           dataTask: URLSessionDataTask,
                           didReceive response: URLResponse,
                           completionHandler: @escaping (URLSession.ResponseDisposition) -> Void) {
        
        if let stream,
           let responseContinuation {
            responseContinuation.resume(returning: (stream, response))
            self.responseContinuation = nil
        }
        completionHandler(.allow)
    }
    
    public func urlSession(_ session: URLSession,
                           dataTask: URLSessionDataTask,
                           didReceive data: Data) {
        continuation?.yield(data)
    }
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didCompleteWithError error: Error?) {
        if let error {
            responseContinuation?.resume(throwing: error)
            continuation?.finish(throwing: error)
        } else {
            continuation?.finish()
        }
    }
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           willPerformHTTPRedirection response: HTTPURLResponse,
                           newRequest request: URLRequest,
                           completionHandler: @escaping @Sendable (URLRequest?) -> Void) {
        if let delegate,
           delegate.responds(to: #selector(URLSessionTaskDelegate.urlSession(_:task:willPerformHTTPRedirection:newRequest:))) {
            delegate.urlSession?(session, task: task, willPerformHTTPRedirection: response, newRequest: request, completionHandler: completionHandler)
        } else {
            completionHandler(request)
        }
    }
    
    public func urlSession(_ session: URLSession,
                           task: URLSessionTask,
                           didReceive challenge: URLAuthenticationChallenge,
                           completionHandler: @escaping @Sendable (URLSession.AuthChallengeDisposition, URLCredential?) -> Void) {
        if let delegate,
           delegate.responds(to: #selector(URLSessionTaskDelegate.urlSession(_:task:didReceive:completionHandler:))) {
            delegate.urlSession?(session, task: task, didReceive: challenge, completionHandler: completionHandler)
        } else {
            completionHandler(.performDefaultHandling, nil)
        }
    }
    
    public func urlSession(_ session: URLSession,
                           taskIsWaitingForConnectivity task: URLSessionTask) {
        delegate?.urlSession?(session, taskIsWaitingForConnectivity: task)
    }
}
