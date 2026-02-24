//
//  UnsplashEndpointsTests.swift
//  PinBoard
//
//  Created by Galia on 2/24/26.
//

import Testing
import Foundation
@testable import PinBoard

@Suite("Unsplash Endpoints")
struct UnsplashEndpointsTests {

    @Test func photosEndpoint_path() {
        let endpoint = UnsplashEndpoint.photos(page: 1)
        #expect(endpoint.path == "photos")
    }

    @Test func photosEndpoint_method() {
        let endpoint = UnsplashEndpoint.photos(page: 1)
        #expect(endpoint.method == .get)
    }

    @Test func photosEndpoint_queryItems() {
        let endpoint = UnsplashEndpoint.photos(page: 3, perPage: 15)
        let queryItems = endpoint.queryItems!

        #expect(queryItems.contains(URLQueryItem(name: "page", value: "3")))
        #expect(queryItems.contains(URLQueryItem(name: "per_page", value: "15")))
        #expect(queryItems.contains(URLQueryItem(name: "order_by", value: "popular")))
    }

    @Test func photosEndpoint_defaultPerPage() {
        let endpoint = UnsplashEndpoint.photos(page: 1)
        let queryItems = endpoint.queryItems!
        #expect(queryItems.contains(URLQueryItem(name: "per_page", value: "20")))
    }

    @Test func photoDetailEndpoint_path() {
        let endpoint = UnsplashEndpoint.photo(id: "abc-123")
        #expect(endpoint.path == "photos/abc-123")
    }

    @Test func photoDetailEndpoint_method() {
        let endpoint = UnsplashEndpoint.photo(id: "abc-123")
        #expect(endpoint.method == .get)
    }

    @Test func photoDetailEndpoint_noQueryItems() {
        let endpoint = UnsplashEndpoint.photo(id: "abc-123")
        #expect(endpoint.queryItems == nil)
    }
}
