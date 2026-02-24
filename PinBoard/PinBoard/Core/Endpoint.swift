//
//  Endpoint.swift
//  PinBoard
//
//  Created by Galia on 2/24/26.
//
import Foundation

enum HTTPMethod: String { case get = "GET", post = "POST" }

protocol Endpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var queryItems: [URLQueryItem]? { get }
}

extension Endpoint {
    var method: HTTPMethod { .get }
    var queryItems: [URLQueryItem]? { nil }

    func url(baseURL: URL) -> URL {
        let fullUrl = baseURL.appending(path: path)
        if let queryItems = queryItems {
            return fullUrl.appending(queryItems: queryItems)
        }
        return fullUrl
    }
}
