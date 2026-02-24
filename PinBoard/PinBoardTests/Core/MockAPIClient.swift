
//
//  MockAPIClient.swift.swift
//  PinBoard
//
//  Created by Galia on 2/24/26.
//

import Foundation
@testable import PinBoard

final class MockAPIClient: APIClientProtocol {
    var stubbedResult: Result<Any, Error> = .failure(APIError.general)
    private(set) var requestedEndpoints: [any Endpoint] = []

    func request<T: Decodable>(_ endpoint: any Endpoint) async throws -> T {
        requestedEndpoints.append(endpoint)
        switch stubbedResult {
        case .success(let value):
            guard let typed = value as? T else {
                throw APIError.decodingError(
                    NSError(domain: "MockAPIClient", code: 0,
                            userInfo: [NSLocalizedDescriptionKey: "Type mismatch in mock"])
                )
            }
            return typed
        case .failure(let error):
            throw error
        }
    }

    var lastRequestedEndpoint: (any Endpoint)? {
        requestedEndpoints.last
    }
}
