import UIKit
import Nuke

// MARK: - Protocol

/// Abstraction over image caching, allowing swapping implementations (e.g. Nuke, custom disk cache).
protocol ImageCaching {
    func cachedImage(for url: URL) -> UIImage?
    func store(_ image: UIImage, for url: URL)
    func removeAll()
}

// MARK: - Nuke Implementation

final class NukeImageCache: ImageCaching {
    private let pipeline: ImagePipeline

    init(pipeline: ImagePipeline = .shared) {
        self.pipeline = pipeline
    }

    func cachedImage(for url: URL) -> UIImage? {
        let request = ImageRequest(url: url)
        return pipeline.cache[request]?.image
    }

    func store(_ image: UIImage, for url: URL) {
        let request = ImageRequest(url: url)
        pipeline.cache[request] = ImageContainer(image: image)
    }

    func removeAll() {
        pipeline.cache.removeAll()
    }
}
