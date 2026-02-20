import Foundation

enum UnsplashEndpoint: Endpoint {
    case photos(page: Int, perPage: Int = 20)
    case photo(id: String)

    var path: String {
        switch self {
        case .photos:
            return "/photos"
        case .photo(let id):
            return "/photos/\(id)"
        }
    }

    var method: HTTPMethod { .get }

    var queryItems: [URLQueryItem]? {
        switch self {
        case .photos(let page, let perPage):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)"),
                URLQueryItem(name: "order_by", value: "popular")
            ]
        case .photo:
            return nil
        }
    }
}
