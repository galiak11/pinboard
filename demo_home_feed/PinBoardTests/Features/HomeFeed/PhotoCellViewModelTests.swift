import Testing
import Foundation
@testable import PinBoard

@Suite("PhotoCellViewModel")
struct PhotoCellViewModelTests {

    // MARK: - Likes Formatting

    @Test func likesFormatting_zero() {
        #expect(PhotoCellViewModel.formatLikes(0) == "No likes yet")
    }

    @Test func likesFormatting_singular() {
        #expect(PhotoCellViewModel.formatLikes(1) == "1 like")
    }

    @Test func likesFormatting_hundreds() {
        #expect(PhotoCellViewModel.formatLikes(500) == "500 likes")
    }

    @Test func likesFormatting_thousands() {
        #expect(PhotoCellViewModel.formatLikes(14500) == "14.5K likes")
    }

    @Test func likesFormatting_exactThousand() {
        #expect(PhotoCellViewModel.formatLikes(1000) == "1.0K likes")
    }

    // MARK: - Aspect Ratio

    @Test func aspectRatio_landscape() {
        let photo = TestFixtures.makePhoto(width: 6000, height: 4000)
        let vm = PhotoCellViewModel(photo: photo)
        #expect(abs(vm.aspectRatio - (4000.0 / 6000.0)) < 0.001)
    }

    @Test func aspectRatio_portrait() {
        let photo = TestFixtures.makePhoto(width: 3000, height: 6000)
        let vm = PhotoCellViewModel(photo: photo)
        #expect(abs(vm.aspectRatio - 2.0) < 0.001)
    }

    @Test func aspectRatio_square() {
        let photo = TestFixtures.makePhoto(width: 3000, height: 3000)
        let vm = PhotoCellViewModel(photo: photo)
        #expect(abs(vm.aspectRatio - 1.0) < 0.001)
    }

    @Test func aspectRatio_zeroWidth_fallsBackToOne() {
        let photo = TestFixtures.makePhoto(width: 0, height: 3000)
        let vm = PhotoCellViewModel(photo: photo)
        #expect(vm.aspectRatio == 1.0)
    }

    // MARK: - Description Fallback

    @Test func nilDescription_usesAltDescription() {
        let photo = TestFixtures.makePhoto(description: nil, altDescription: "Alt text here")
        let vm = PhotoCellViewModel(photo: photo)
        #expect(vm.title == "Alt text here")
    }

    @Test func nilBothDescriptions_usesEmptyString() {
        let photo = TestFixtures.makePhoto(description: nil, altDescription: nil)
        let vm = PhotoCellViewModel(photo: photo)
        #expect(vm.title == "")
    }

    @Test func description_prefersPrimaryOverAlt() {
        let photo = TestFixtures.makePhoto(description: "Primary", altDescription: "Alt")
        let vm = PhotoCellViewModel(photo: photo)
        #expect(vm.title == "Primary")
    }

    // MARK: - Other Fields

    @Test func authorName() {
        let photo = TestFixtures.makePhoto(userDisplayName: "Jane Smith")
        let vm = PhotoCellViewModel(photo: photo)
        #expect(vm.authorName == "Jane Smith")
    }

    @Test func imageURL_usesSmall() {
        let photo = TestFixtures.makePhoto()
        let vm = PhotoCellViewModel(photo: photo)
        #expect(vm.imageURL == URL(string: "https://example.com/small.jpg"))
    }
}
