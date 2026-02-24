//
//  APIError.swift
//  PinBoard
//
//  Created by Galia on 2/24/26.
//

import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL(String)
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    case general
    
    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL."
        case .httpError(let statusCode):
            return "Server error (HTTP \(statusCode))."
        case .decodingError:
            return "Failed to parse server response."
        case .networkError(let error):
            return error.localizedDescription
        case .general:
            return "A general or unknown error occurred."
        }
    }
}
