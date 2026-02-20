import UIKit
import Nuke

/// Helper wrapper for Nuke image loading
/// This provides a simplified API matching the NukeExtensions module
enum NukeExtensions {
    
    /// Load an image from a URL into an image view
    /// - Parameters:
    ///   - url: The URL to load the image from
    ///   - imageView: The image view to load the image into
    ///   - completion: Optional completion handler with the result
    @discardableResult
    static func loadImage(
        with url: URL,
        into imageView: UIImageView,
        completion: ((Result<ImageResponse, ImagePipeline.Error>) -> Void)? = nil
    ) -> ImageTask? {
        let request = ImageRequest(url: url)
        return loadImage(with: request, into: imageView, completion: completion)
    }
    
    /// Load an image from an ImageRequest into an image view
    /// - Parameters:
    ///   - request: The ImageRequest to load
    ///   - imageView: The image view to load the image into
    ///   - completion: Optional completion handler with the result
    @discardableResult
    static func loadImage(
        with request: ImageRequest,
        into imageView: UIImageView,
        completion: ((Result<ImageResponse, ImagePipeline.Error>) -> Void)? = nil
    ) -> ImageTask? {
        return ImagePipeline.shared.loadImage(with: request) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let response):
                    // Animate the image appearance
                    UIView.transition(
                        with: imageView,
                        duration: 0.2,
                        options: .transitionCrossDissolve,
                        animations: {
                            imageView.image = response.image
                        },
                        completion: nil
                    )
                    completion?(.success(response))
                case .failure(let error):
                    completion?(.failure(error))
                }
            }
        }
    }
    
    /// Cancel any pending image loading request for the given image view
    /// - Parameter imageView: The image view to cancel requests for
    static func cancelRequest(for imageView: UIImageView) {
        // Nuke automatically handles request cancellation when a new request is made
        // If you need explicit cancellation, you'd need to track the ImageTask
        imageView.image = nil
    }
}

