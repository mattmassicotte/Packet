import XCTest
@testable import Packet

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
}
