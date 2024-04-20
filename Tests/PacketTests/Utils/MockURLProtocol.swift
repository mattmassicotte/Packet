//
//  File.swift
//
//
//  Created by iain on 20/04/2024.
//

import Foundation
import XCTest


enum MockSchemes: String {
    case authenticate = "authenticate"
    case redirect = "redirect"
    case error = "error"
}

enum MockError: Error {
    case errorRequested
}

class MockURLProtocol<Responder: MockURLResponder>: URLProtocol, URLAuthenticationChallengeSender {
    override class func canInit(with request: URLRequest) -> Bool {
        true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        request
    }
    
    override func startLoading() {
        guard let client = client else {
            return
        }
                
        do {
            let url = try XCTUnwrap(request.url)

            // Here we try to get data from our responder type, and
            // we then send that data, as well as a HTTP response,
            // to our client. If any of those operations fail,
            // we send an error instead:
            let data = try Responder.respond(to: request)
    
            let response = try XCTUnwrap(HTTPURLResponse(
                url: url,
                statusCode: 200,
                httpVersion: "HTTP/1.1",
                headerFields: nil
            ))
            
            let scheme = url.scheme ?? ""
            
            if scheme == MockSchemes.authenticate.rawValue {
                client.urlProtocol(self,
                                   didReceive: URLAuthenticationChallenge(protectionSpace: URLProtectionSpace(host: "www.example.com", port: 8080, protocol: nil, realm: nil, authenticationMethod: nil),
                                                                          proposedCredential: nil,
                                                                          previousFailureCount: 0,
                                                                          failureResponse: nil,
                                                                          error: nil,
                                                                          sender: self))
            }
            
            if scheme == MockSchemes.redirect.rawValue {
                let newRequest = URLRequest(url: URL(string: "https://www.example.com")!)
                client.urlProtocol(self,
                                   wasRedirectedTo: newRequest,
                                   redirectResponse: response)
            }
            
            if scheme == MockSchemes.error.rawValue {
                throw MockError.errorRequested
            }
            
            client.urlProtocol(self,
                               didReceive: response,
                               cacheStoragePolicy: .notAllowed
            )
            client.urlProtocol(self, didLoad: data)
        } catch {
            client.urlProtocol(self, didFailWithError: error)
        }
        
        client.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {
    }
    
    func use(_ credential: URLCredential, for challenge: URLAuthenticationChallenge) {
    }
    
    func continueWithoutCredential(for challenge: URLAuthenticationChallenge) {
    }
    
    func cancel(_ challenge: URLAuthenticationChallenge) {
    }
}
