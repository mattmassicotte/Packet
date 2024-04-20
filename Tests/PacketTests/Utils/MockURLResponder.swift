import Foundation

protocol MockURLResponder {
    static func respond(to request: URLRequest) throws -> Data
}
