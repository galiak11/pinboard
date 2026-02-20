import Foundation
@testable import PinBoard

/// Anchor class for locating the test bundle in Swift Testing (which uses structs, not classes)
final class TestBundleAnchor {}

enum TestFixtures {
    /// Returns the test target's bundle (works from both XCTest and Swift Testing contexts)
    static var bundle: Bundle { Bundle(for: TestBundleAnchor.self) }

    static func loadFixture(_ name: String) throws -> Data {
        guard let url = bundle.url(forResource: name, withExtension: "json") else {
            throw NSError(
                domain: "TestFixture",
                code: 0,
                userInfo: [NSLocalizedDescriptionKey: "Fixture \(name).json not found in test bundle"]
            )
        }
        return try Data(contentsOf: url)
    }

    static func makePhoto(
        id: String = "abc123",
        description: String? = "A beautiful landscape",
        altDescription: String? = "Mountain view",
        width: Int = 4000,
        height: Int = 3000,
        likes: Int = 150,
        createdAt: Date? = Date(timeIntervalSince1970: 1700000000),
        userName: String = "johndoe",
        userDisplayName: String = "John Doe",
        exif: UnsplashExif? = nil,
        location: UnsplashLocation? = nil
    ) -> UnsplashPhoto {
        UnsplashPhoto(
            id: id,
            description: description,
            altDescription: altDescription,
            width: width,
            height: height,
            likes: likes,
            createdAt: createdAt,
            user: makeUser(username: userName, name: userDisplayName),
            urls: makeURLs(),
            exif: exif,
            location: location
        )
    }

    static func makeUser(
        id: String = "user1",
        username: String = "johndoe",
        name: String = "John Doe"
    ) -> UnsplashUser {
        UnsplashUser(
            id: id,
            username: username,
            name: name,
            profileImage: UnsplashUser.ProfileImageURLs(
                small: URL(string: "https://example.com/avatar_small.jpg")!,
                medium: URL(string: "https://example.com/avatar_medium.jpg")!,
                large: URL(string: "https://example.com/avatar_large.jpg")!
            )
        )
    }

    static func makeURLs() -> UnsplashPhotoURLs {
        UnsplashPhotoURLs(
            raw: URL(string: "https://example.com/raw.jpg")!,
            full: URL(string: "https://example.com/full.jpg")!,
            regular: URL(string: "https://example.com/regular.jpg")!,
            small: URL(string: "https://example.com/small.jpg")!,
            thumb: URL(string: "https://example.com/thumb.jpg")!
        )
    }

    static func makePhotoList(count: Int = 20) -> [UnsplashPhoto] {
        (0..<count).map { i in
            makePhoto(
                id: "photo-\(i)",
                description: "Photo \(i)",
                width: 4000,
                height: Int.random(in: 3000...6000),
                likes: i * 100
            )
        }
    }

    static func makeExif(
        make: String? = "Canon",
        model: String? = "EOS R5",
        exposureTime: String? = "1/500",
        aperture: String? = "2.8",
        focalLength: String? = "85",
        iso: Int? = 400
    ) -> UnsplashExif {
        UnsplashExif(
            make: make,
            model: model,
            exposureTime: exposureTime,
            aperture: aperture,
            focalLength: focalLength,
            iso: iso
        )
    }

    static func makeLocation(
        name: String? = "Yosemite National Park",
        city: String? = "Yosemite",
        country: String? = "United States"
    ) -> UnsplashLocation {
        UnsplashLocation(name: name, city: city, country: country)
    }
}
