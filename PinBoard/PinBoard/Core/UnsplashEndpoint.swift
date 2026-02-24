//
//  UnsplashEndpoint.swift
//  PinBoard
//
//  Created by Galia on 2/24/26.
//

import Foundation

enum UnsplashEndpoint: Endpoint {
    case photos(page: Int, perPage: Int = 20, orderBy: String = "popular")
    case photo(id: String)
    
    var baseURL: URL {
        URL(string: "https://api.unsplash.com")!
    }
    
    var path: String {
        switch self {
        case .photos:
            return "photos"
        case .photo(let id):
            return "photos/\(id)"
        }
    }
    
    var queryItems: [URLQueryItem]? {
        switch self {
        case .photos(let page, let perPage, let orderBy):
            return [
                URLQueryItem(name: "page", value: "\(page)"),
                URLQueryItem(name: "per_page", value: "\(perPage)"),
                URLQueryItem(name: "order_by", value: orderBy)
            ]
        case .photo:
            return nil
        }
    }
}
