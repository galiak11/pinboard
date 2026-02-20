import Foundation

enum APIError: Error, LocalizedError {
    case invalidURL
    case httpError(statusCode: Int)
    case decodingError(Error)
    case networkError(Error)
    case unknown

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
        case .unknown:
            return "An unknown error occurred."
        }
    }
}
