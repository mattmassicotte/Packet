import XCTest
@testable import Packet

final class SuccessfulResponder: MockURLResponder {
    static let url = Bundle.module.url(forResource: "ipsum100k", withExtension: "txt")
    static func respond(to request: URLRequest) throws -> Data {
        let data = try Data(contentsOf: XCTUnwrap(url))
        return data
    }
}

extension URLSession {
    convenience init<T: MockURLResponder>(mockResponder: T.Type) {
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol<T>.self]
        self.init(configuration: config)
        URLProtocol.registerClass(MockURLProtocol<T>.self)
    }
}

final class URLSessionTests: XCTestCase {
    @available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, *)
    func testURL() async throws {
        let testURL = Bundle.module.url(forResource: "ipsum100k", withExtension: "txt")
        XCTAssertNotNil(testURL, "Unable to find test file")
        
        let attrs = try FileManager.default.attributesOfItem(atPath: testURL!.path(percentEncoded: false))
        let fileSize = attrs[.size] as? UInt64 ?? UInt64(0)
        
        var byteCount = 0
        let chunkStream = URLSession.shared.chunks(for: testURL!)
        for try await data in chunkStream {
            byteCount += data.count
        }
        
        XCTAssert(byteCount == fileSize)
    }
    
    @available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, *)
    func testURLRequest() async throws {
        let testURL = Bundle.module.url(forResource: "ipsum100k", withExtension: "txt")
        XCTAssertNotNil(testURL, "Unable to find test file")
        
        let attrs = try FileManager.default.attributesOfItem(atPath: testURL!.path(percentEncoded: false))
        let fileSize = attrs[.size] as? UInt64 ?? UInt64(0)
        
        var byteCount = 0
        let request = URLRequest(url: testURL!)
        let chunkStream = URLSession.shared.chunks(for: request)
        for try await data in chunkStream {
            byteCount += data.count
        }
        
        XCTAssert(byteCount == fileSize)
    }
    
    @available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, *)
    func testAuthenticationDelegate() async throws {
        // Replace the session's URLResponder that fakes an authentication challenge
        // to make sure the delegate is handling it correctly
        let session = URLSession(mockResponder: SuccessfulResponder.self)
        let chunkStream = session.chunks(for: URL(string:"\(MockSchemes.authenticate.rawValue)://fakefile")!)
        for try await _ in chunkStream {
            // Don't really care about the chunk in this case, it's been tested
            // earlier, just testing that an authentication request doesn't fail
        }
    }

    @available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, *)
    func testRedirectDelegate() async throws {
        // Replace the session's URLResponder that fakes an authentication challenge
        // to make sure the delegate is handling it correctly
        let session = URLSession(mockResponder: SuccessfulResponder.self)
        let chunkStream = session.chunks(for: URL(string:"\(MockSchemes.redirect.rawValue)://fakefile")!)
        for try await _ in chunkStream {
            // Don't really care about the chunk in this case, it's been tested
            // earlier, just testing that an authentication request doesn't fail
        }
    }
    
    @available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, *)
    func testErrorDelegate() async throws {
        await assertThrowsAsyncError(try await errorStream()) { error in
            XCTAssertNotNil(error)
        }
    }
    
    @available(iOS 16.0, macOS 13.0, macCatalyst 16.0, tvOS 16.0, watchOS 9.0, *)
    private func errorStream() async throws {
        // Replace the session's URLResponder that fakes an authentication challenge
        // to make sure the delegate is handling it correctly
        let session = URLSession(mockResponder: SuccessfulResponder.self)
        let chunkStream = session.chunks(for: URL(string:"\(MockSchemes.error.rawValue)://fakefile")!)
        for try await _ in chunkStream {
            // Don't really care about the chunk in this case, it's been tested
            // earlier, just testing that an authentication request doesn't fail
        }
    }
}
