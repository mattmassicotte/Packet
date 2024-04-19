import Foundation

extension URL {
    /// The URL's resource data, as an asynchronous sequence of ``Data`` chunks
    ///
    /// Use this property with Swift's `for-await-in` syntax to read the contents of a URL in chunks like this:
    /// ```swift
    /// guard let url = URL(string: "https://www.example.com") else {
    ///     return
    /// }
    ///
    /// do {
    ///     // Read each chunk of the data as it becomes available
    ///     for try await chunk in url.resourceChunks {
    ///         // Do something with chunk
    ///     }
    /// } catch {
    ///     print("Error: \(error)")
    /// }
    @available(iOS 15.0, macOS 12.0, macCatalyst 15.0, tvOS 15.0, watchOS 8.0, *)
    public var resourceChunks: AsyncThrowingDataChunks {
        return URLSession.shared.chunks(for: self)
    }
}
