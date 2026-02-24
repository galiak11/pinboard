//
//  APIClient.swift
//  PinBoard
//
//  Created by Galia on 2/24/26.
//

import Foundation

class APIClient: APIClientProtocol {
    let session: URLSession
    let accessKey: String
    let baseURL: URL
    
    init(session: URLSession, accessKey: String, baseURLString: String = "unsplash") throws {
        guard let url = URL(string: baseURLString) else { throw APIError.invalidURL(baseURLString) }

        self.session = session
        self.accessKey = accessKey
        self.baseURL = url
    }
    
    func request<T: Decodable>(_ endpoint: Endpoint) async throws -> T {
        let url = endpoint.url(baseURL: baseURL)
        
        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("Client-ID \(accessKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Accept")
        
        let data: Data
        let response: URLResponse
        
        do {
            (data, response) = try await session.data(for: request)
        } catch {
            throw APIError.networkError(error)
        }
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw APIError.general
        }
        
        guard (200...299).contains(httpResponse.statusCode) else {
            throw APIError.httpError(statusCode: httpResponse.statusCode)
        }
        
        do {
            let decoder = JSONDecoder()
            decoder.keyDecodingStrategy = .convertFromSnakeCase
            decoder.dateDecodingStrategy = .iso8601
            return try decoder.decode(T.self, from: data)
        } catch {
            throw APIError.decodingError(error)
        }
    }
}
