//
//  MockURLProtocol.swift
//  PinBoard
//
//  Created by Galia on 2/24/26.
//

import Foundation

final class MockURLProtocol: URLProtocol {
    static var stubbedData: Data?
    static var stubbedResponse: HTTPURLResponse?
    static var stubbedError: Error?
    static var lastRequest: URLRequest?

    override class func canInit(with request: URLRequest) -> Bool { true }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest { request }

    override func startLoading() {
        MockURLProtocol.lastRequest = request

        if let error = MockURLProtocol.stubbedError {
            client?.urlProtocol(self, didFailWithError: error)
            return
        }

        if let response = MockURLProtocol.stubbedResponse {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
        }

        if let data = MockURLProtocol.stubbedData {
            client?.urlProtocol(self, didLoad: data)
        }

        client?.urlProtocolDidFinishLoading(self)
    }

    override func stopLoading() {}

    static func reset() {
        stubbedData = nil
        stubbedResponse = nil
        stubbedError = nil
        lastRequest = nil
    }
}
