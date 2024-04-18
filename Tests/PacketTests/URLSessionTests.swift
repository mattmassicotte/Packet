import XCTest
@testable import Packet

final class URLSessionTests: XCTestCase {
    func testChunks() async throws {
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
}
