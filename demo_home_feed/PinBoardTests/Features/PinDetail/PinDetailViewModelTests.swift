import Testing
import Combine
import Foundation
@testable import PinBoard

@Suite("PinDetailViewModel")
struct PinDetailViewModelTests {

    // MARK: - State Transitions

    @Test func loadDetail_success_formatsAllFields() async throws {
        let mockService = MockPinDetailService()
        let photo = TestFixtures.makePhoto(
            description: "A beautiful landscape",
            likes: 1234,
            createdAt: Date(timeIntervalSince1970: 1718448600),
            userDisplayName: "Nature Photo",
            exif: TestFixtures.makeExif(),
            location: TestFixtures.makeLocation()
        )
        mockService.stubbedResult = .success(photo)
        let sut = PinDetailViewModel(photoID: "test-id", service: mockService)

        sut.viewDidLoad()
        try await Task.sleep(for: .milliseconds(200))

        #expect(sut.state == .loaded)
        #expect(sut.titleText == "A beautiful landscape")
        #expect(sut.authorName == "Nature Photo")
        #expect(sut.likesText == "1.2K likes")
        #expect(!sut.dateText.isEmpty)
        #expect(sut.imageURL == URL(string: "https://example.com/regular.jpg"))
    }

    @Test func loadDetail_failure_showsError() async throws {
        let mockService = MockPinDetailService()
        mockService.stubbedResult = .failure(APIError.httpError(statusCode: 404))
        let sut = PinDetailViewModel(photoID: "test-id", service: mockService)

        sut.viewDidLoad()
        try await Task.sleep(for: .milliseconds(200))

        if case .error = sut.state {
            // expected
        } else {
            Issue.record("Expected .error state, got \(sut.state)")
        }
    }

    @Test func loadDetail_callsServiceWithCorrectID() async throws {
        let mockService = MockPinDetailService()
        let photo = TestFixtures.makePhoto()
        mockService.stubbedResult = .success(photo)
        let sut = PinDetailViewModel(photoID: "test-id", service: mockService)

        sut.viewDidLoad()
        try await Task.sleep(for: .milliseconds(200))

        #expect(mockService.fetchCalledWithIDs == ["test-id"])
    }

    // MARK: - Date Formatting

    @Test func dateFormatting_validDate() {
        let mockService = MockPinDetailService()
        let sut = PinDetailViewModel(photoID: "test-id", service: mockService)
        let date = Date(timeIntervalSince1970: 1718448600)
        let result = sut.formatDate(date)
        #expect(!result.isEmpty)
    }

    @Test func dateFormatting_nilDate() {
        let mockService = MockPinDetailService()
        let sut = PinDetailViewModel(photoID: "test-id", service: mockService)
        let result = sut.formatDate(nil)
        #expect(result == "")
    }

    // MARK: - EXIF Formatting

    @Test func exifFormatting_allFieldsPresent() {
        let mockService = MockPinDetailService()
        let sut = PinDetailViewModel(photoID: "test-id", service: mockService)
        let exif = TestFixtures.makeExif()
        let result = sut.formatExif(exif)
        #expect(result.contains("Canon"))
        #expect(result.contains("EOS R5"))
        #expect(result.contains("f/2.8"))
        #expect(result.contains("1/500s"))
        #expect(result.contains("ISO 400"))
    }

    @Test func exifFormatting_partialFields() {
        let mockService = MockPinDetailService()
        let sut = PinDetailViewModel(photoID: "test-id", service: mockService)
        let exif = UnsplashExif(
            make: nil,
            model: "iPhone 15 Pro",
            exposureTime: nil,
            aperture: "1.8",
            focalLength: nil,
            iso: 100
        )
        let result = sut.formatExif(exif)
        #expect(result.contains("iPhone 15 Pro"))
        #expect(result.contains("f/1.8"))
        #expect(result.contains("ISO 100"))
        #expect(!result.contains("nil"))
    }

    @Test func exifFormatting_nilExif() {
        let mockService = MockPinDetailService()
        let sut = PinDetailViewModel(photoID: "test-id", service: mockService)
        let result = sut.formatExif(nil)
        #expect(result == "")
    }

    // MARK: - Location Formatting

    @Test func locationFormatting_cityAndCountry() {
        let mockService = MockPinDetailService()
        let sut = PinDetailViewModel(photoID: "test-id", service: mockService)
        let location = TestFixtures.makeLocation(city: "Paris", country: "France")
        let result = sut.formatLocation(location)
        #expect(result == "Paris, France")
    }

    @Test func locationFormatting_onlyName() {
        let mockService = MockPinDetailService()
        let sut = PinDetailViewModel(photoID: "test-id", service: mockService)
        let location = UnsplashLocation(name: "Central Park", city: nil, country: nil)
        let result = sut.formatLocation(location)
        #expect(result == "Central Park")
    }

    @Test func locationFormatting_nil() {
        let mockService = MockPinDetailService()
        let sut = PinDetailViewModel(photoID: "test-id", service: mockService)
        let result = sut.formatLocation(nil)
        #expect(result == "")
    }

    // MARK: - Description Fallback

    @Test func nilDescription_fallback() async throws {
        let mockService = MockPinDetailService()
        let photo = TestFixtures.makePhoto(description: nil, altDescription: "Alt desc")
        mockService.stubbedResult = .success(photo)
        let sut = PinDetailViewModel(photoID: "test-id", service: mockService)

        sut.viewDidLoad()
        try await Task.sleep(for: .milliseconds(200))

        #expect(sut.titleText == "Alt desc")
    }
}
