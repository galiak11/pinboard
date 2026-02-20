import Testing
import Foundation
@testable import PinBoard

@Suite("Model Decoding")
struct ModelDecodingTests {
    let decoder: JSONDecoder = {
        let d = JSONDecoder()
        d.keyDecodingStrategy = .convertFromSnakeCase
        d.dateDecodingStrategy = .iso8601
        return d
    }()

    // MARK: - Photo List

    @Test func decodePhotoListFromJSON() throws {
        let data = try TestFixtures.loadFixture("photos_page1")
        let photos = try decoder.decode([UnsplashPhoto].self, from: data)

        #expect(photos.count == 3)

        let first = photos[0]
        #expect(first.id == "photo-001")
        #expect(first.description == "Sunset over the mountains")
        #expect(first.width == 4000)
        #expect(first.height == 6000)
        #expect(first.likes == 1234)
        #expect(first.user.name == "Nature Photographer")
        #expect(first.user.username == "naturephoto")
        #expect(first.createdAt != nil)
    }

    @Test func decodePhoto_nilDescription() throws {
        let data = try TestFixtures.loadFixture("photos_page1")
        let photos = try decoder.decode([UnsplashPhoto].self, from: data)

        let second = photos[1]
        #expect(second.description == nil)
        #expect(second.altDescription == "A city skyline at night")
    }

    @Test func decodePhoto_zeroLikes() throws {
        let data = try TestFixtures.loadFixture("photos_page1")
        let photos = try decoder.decode([UnsplashPhoto].self, from: data)

        let third = photos[2]
        #expect(third.likes == 0)
    }

    // MARK: - Photo Detail

    @Test func decodePhotoDetail_withExif() throws {
        let data = try TestFixtures.loadFixture("photo_detail")
        let photo = try decoder.decode(UnsplashPhoto.self, from: data)

        #expect(photo.id == "photo-001")
        #expect(photo.exif != nil)
        #expect(photo.exif?.make == "Canon")
        #expect(photo.exif?.model == "EOS R5")
        #expect(photo.exif?.aperture == "2.8")
        #expect(photo.exif?.exposureTime == "1/500")
        #expect(photo.exif?.iso == 400)
    }

    @Test func decodePhotoDetail_withLocation() throws {
        let data = try TestFixtures.loadFixture("photo_detail")
        let photo = try decoder.decode(UnsplashPhoto.self, from: data)

        #expect(photo.location != nil)
        #expect(photo.location?.city == "Yosemite Village")
        #expect(photo.location?.country == "United States")
    }

    @Test func decodePhotoDetail_withoutExif() throws {
        let data = try TestFixtures.loadFixture("photos_page1")
        let photos = try decoder.decode([UnsplashPhoto].self, from: data)

        #expect(photos[0].exif == nil)
    }

    @Test func decodeUser_profileImage() throws {
        let data = try TestFixtures.loadFixture("photo_detail")
        let photo = try decoder.decode(UnsplashPhoto.self, from: data)

        #expect(photo.user.profileImage != nil)
        #expect(photo.user.profileImage?.small != nil)
        #expect(photo.user.profileImage?.medium != nil)
        #expect(photo.user.profileImage?.large != nil)
    }
}
