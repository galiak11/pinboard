//
//  APIClientProtocol.swift
//  PinBoard
//
//  Created by Galia on 2/24/26.
//

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T
}
