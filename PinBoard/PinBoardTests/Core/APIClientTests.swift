//
//  APIClientTests.swift
//  PinBoard
//
//  Created by Galia on 2/24/26.
//

import XCTest
@testable import PinBoard

@MainActor
final class APIClientTests: XCTestCase {
    private var sut: APIClient!
    private var session: URLSession!

    override func setUp() {
        super.setUp()
        let config = URLSessionConfiguration.ephemeral
        config.protocolClasses = [MockURLProtocol.self]
        session = URLSession(configuration: config)
        sut = try! APIClient(
            session: session,
            accessKey: "test-key",
            baseURLString: "https://api.unsplash.com",
        )
    }

    override func tearDown() {
        MockURLProtocol.reset()
        sut = nil
        session = nil
        super.tearDown()
    }

    // Use a small local Decodable type for APIClient decoding tests so
    // this exercise doesn't depend on the Unsplash model definitions.
    private struct Dummy: Decodable {
        let id: String
    }

    func testRequest_success_decodesJSON() async throws {
        let json = """
        [{"id":"1"}]
        """.data(using: .utf8)!

        MockURLProtocol.stubbedData = json
        MockURLProtocol.stubbedResponse = HTTPURLResponse(
            url: URL(string: "https://api.unsplash.com/photos")!,
            statusCode: 200, httpVersion: nil, headerFields: nil
        )

        let items: [Dummy] = try await sut.request(
            UnsplashEndpoint.photos(page: 1)
        )
        XCTAssertEqual(items.count, 1)
        XCTAssertEqual(items.first?.id, "1")
    }

    func testRequest_httpError_throwsAPIError() async {
        MockURLProtocol.stubbedData = Data()
        MockURLProtocol.stubbedResponse = HTTPURLResponse(
            url: URL(string: "https://api.unsplash.com/photos")!,
            statusCode: 403, httpVersion: nil, headerFields: nil
        )

        do {
            let _: [Dummy] = try await sut.request(
                UnsplashEndpoint.photos(page: 1)
            )
            XCTFail("Expected error")
        } catch let error as APIError {
            if case .httpError(let code) = error {
                XCTAssertEqual(code, 403)
            } else {
                XCTFail("Wrong APIError case: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testRequest_invalidJSON_throwsDecodingError() async {
        MockURLProtocol.stubbedData = "not json".data(using: .utf8)!
        MockURLProtocol.stubbedResponse = HTTPURLResponse(
            url: URL(string: "https://api.unsplash.com/photos")!,
            statusCode: 200, httpVersion: nil, headerFields: nil
        )

        do {
            let _: [Dummy] = try await sut.request(
                UnsplashEndpoint.photos(page: 1)
            )
            XCTFail("Expected error")
        } catch let error as APIError {
            if case .decodingError = error {
                // Expected
            } else {
                XCTFail("Wrong APIError case: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testRequest_networkError_throwsAPIError() async {
        MockURLProtocol.stubbedError = NSError(
            domain: NSURLErrorDomain,
            code: NSURLErrorNotConnectedToInternet
        )

        do {
            let _: [Dummy] = try await sut.request(
                UnsplashEndpoint.photos(page: 1)
            )
            XCTFail("Expected error")
        } catch let error as APIError {
            if case .networkError = error {
                // Expected
            } else {
                XCTFail("Wrong APIError case: \(error)")
            }
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func testRequest_injectsAuthHeader() async throws {
        let json = "[]".data(using: .utf8)!
        MockURLProtocol.stubbedData = json
        MockURLProtocol.stubbedResponse = HTTPURLResponse(
            url: URL(string: "https://api.unsplash.com/photos")!,
            statusCode: 200, httpVersion: nil, headerFields: nil
        )

        let _: [Dummy] = try await sut.request(
            UnsplashEndpoint.photos(page: 1)
        )

        let authHeader = MockURLProtocol.lastRequest?.value(
            forHTTPHeaderField: "Authorization"
        )
        XCTAssertEqual(authHeader, "Client-ID test-key")
    }
}

//import XCTest
//@testable import PinBoard
//
//final class APIClientTests: XCTestCase {
//    private var sut: APIClient!
//    private var session: URLSession!
//
//    override func setUp() {
//        super.setUp()
//        let config = URLSessionConfiguration.ephemeral
//        config.protocolClasses = [MockURLProtocol.self]
//        session = URLSession(configuration: config)
//        sut = try! APIClient(
//            session: session,
//            accessKey: "test-key",
//            baseURLString: "https://api.unsplash.com",
//        )
//    }
//
//    override func tearDown() {
//        MockURLProtocol.reset()
//        sut = nil
//        session = nil
//        super.tearDown()
//    }
//
//    func testRequest_success_decodesJSON() async throws {
//        let json = """
//        [{"id":"1","description":"Test","alt_description":null,\
//        "width":100,"height":200,"likes":5,\
//        "created_at":"2024-01-01T00:00:00Z",\
//        "user":{"id":"u1","username":"test","name":"Test User",\
//        "profile_image":{"small":"https://example.com/s.jpg",\
//        "medium":"https://example.com/m.jpg",\
//        "large":"https://example.com/l.jpg"}},\
//        "urls":{"raw":"https://example.com/r.jpg",\
//        "full":"https://example.com/f.jpg",\
//        "regular":"https://example.com/re.jpg",\
//        "small":"https://example.com/s.jpg",\
//        "thumb":"https://example.com/t.jpg"},\
//        "exif":null,"location":null}]
//        """.data(using: .utf8)!
//
//        MockURLProtocol.stubbedData = json
//        MockURLProtocol.stubbedResponse = HTTPURLResponse(
//            url: URL(string: "https://api.unsplash.com/photos")!,
//            statusCode: 200, httpVersion: nil, headerFields: nil
//        )
//
//        let photos: [UnsplashPhoto] = try await sut.request(
//            UnsplashEndpoint.photos(page: 1)
//        )
//        XCTAssertEqual(photos.count, 1)
//        XCTAssertEqual(photos.first?.id, "1")
//    }
//
//    func testRequest_httpError_throwsAPIError() async {
//        MockURLProtocol.stubbedData = Data()
//        MockURLProtocol.stubbedResponse = HTTPURLResponse(
//            url: URL(string: "https://api.unsplash.com/photos")!,
//            statusCode: 403, httpVersion: nil, headerFields: nil
//        )
//
//        do {
//            let _: [UnsplashPhoto] = try await sut.request(
//                UnsplashEndpoint.photos(page: 1)
//            )
//            XCTFail("Expected error")
//        } catch let error as APIError {
//            if case .httpError(let code) = error {
//                XCTAssertEqual(code, 403)
//            } else {
//                XCTFail("Wrong APIError case: \(error)")
//            }
//        } catch {
//            XCTFail("Unexpected error: \(error)")
//        }
//    }
//
//    func testRequest_invalidJSON_throwsDecodingError() async {
//        MockURLProtocol.stubbedData = "not json".data(using: .utf8)!
//        MockURLProtocol.stubbedResponse = HTTPURLResponse(
//            url: URL(string: "https://api.unsplash.com/photos")!,
//            statusCode: 200, httpVersion: nil, headerFields: nil
//        )
//
//        do {
//            let _: [UnsplashPhoto] = try await sut.request(
//                UnsplashEndpoint.photos(page: 1)
//            )
//            XCTFail("Expected error")
//        } catch let error as APIError {
//            if case .decodingError = error {
//                // Expected
//            } else {
//                XCTFail("Wrong APIError case: \(error)")
//            }
//        } catch {
//            XCTFail("Unexpected error: \(error)")
//        }
//    }
//
//    func testRequest_networkError_throwsAPIError() async {
//        MockURLProtocol.stubbedError = NSError(
//            domain: NSURLErrorDomain,
//            code: NSURLErrorNotConnectedToInternet
//        )
//
//        do {
//            let _: [UnsplashPhoto] = try await sut.request(
//                UnsplashEndpoint.photos(page: 1)
//            )
//            XCTFail("Expected error")
//        } catch let error as APIError {
//            if case .networkError = error {
//                // Expected
//            } else {
//                XCTFail("Wrong APIError case: \(error)")
//            }
//        } catch {
//            XCTFail("Unexpected error: \(error)")
//        }
//    }
//
//    func testRequest_injectsAuthHeader() async throws {
//        let json = "[]".data(using: .utf8)!
//        MockURLProtocol.stubbedData = json
//        MockURLProtocol.stubbedResponse = HTTPURLResponse(
//            url: URL(string: "https://api.unsplash.com/photos")!,
//            statusCode: 200, httpVersion: nil, headerFields: nil
//        )
//
//        let _: [UnsplashPhoto] = try await sut.request(
//            UnsplashEndpoint.photos(page: 1)
//        )
//
//        let authHeader = MockURLProtocol.lastRequest?.value(
//            forHTTPHeaderField: "Authorization"
//        )
//        XCTAssertEqual(authHeader, "Client-ID test-key")
//    }
//}
