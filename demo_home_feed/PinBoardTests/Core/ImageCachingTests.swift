import Testing
import UIKit
@testable import PinBoard

@Suite("ImageCaching")
struct ImageCachingTests {

    @Test func nukeImageCache_storeAndRetrieve() {
        let cache = NukeImageCache()
        let url = URL(string: "https://example.com/test.jpg")!
        let image = UIImage(systemName: "photo")!

        cache.store(image, for: url)
        let cached = cache.cachedImage(for: url)
        #expect(cached != nil)
    }

    @Test func nukeImageCache_removeAll() {
        let cache = NukeImageCache()
        let url = URL(string: "https://example.com/test2.jpg")!
        let image = UIImage(systemName: "photo")!

        cache.store(image, for: url)
        cache.removeAll()

        let cached = cache.cachedImage(for: url)
        #expect(cached == nil)
    }

    @Test func nukeImageCache_missReturnsNil() {
        let cache = NukeImageCache()
        let url = URL(string: "https://example.com/never-stored.jpg")!
        #expect(cache.cachedImage(for: url) == nil)
    }
}
