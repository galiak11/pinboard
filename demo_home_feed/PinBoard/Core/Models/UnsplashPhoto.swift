import Foundation

struct UnsplashPhoto: Decodable, Equatable {
    let id: String
    let description: String?
    let altDescription: String?
    let width: Int
    let height: Int
    let likes: Int
    let createdAt: Date?
    let user: UnsplashUser
    let urls: UnsplashPhotoURLs
    let exif: UnsplashExif?
    let location: UnsplashLocation?
}

struct UnsplashPhotoURLs: Decodable, Equatable {
    let raw: URL
    let full: URL
    let regular: URL
    let small: URL
    let thumb: URL
}

struct UnsplashExif: Decodable, Equatable {
    let make: String?
    let model: String?
    let exposureTime: String?
    let aperture: String?
    let focalLength: String?
    let iso: Int?
}

struct UnsplashLocation: Decodable, Equatable {
    let name: String?
    let city: String?
    let country: String?
}
