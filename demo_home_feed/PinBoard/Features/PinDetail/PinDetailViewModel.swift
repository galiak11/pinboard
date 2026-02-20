import Foundation
import Combine

final class PinDetailViewModel {
    // MARK: - State

    enum DetailState: Equatable {
        case loading
        case loaded
        case error(String)
    }

    // MARK: - Published Outputs (Combine)

    @Published private(set) var state: DetailState = .loading
    @Published private(set) var imageURL: URL?
    @Published private(set) var titleText: String = ""
    @Published private(set) var authorName: String = ""
    @Published private(set) var authorAvatarURL: URL?
    @Published private(set) var likesText: String = ""
    @Published private(set) var dateText: String = ""
    @Published private(set) var descriptionText: String = ""
    @Published private(set) var exifText: String = ""
    @Published private(set) var locationText: String = ""

    // MARK: - Private

    private let photoID: String
    private let service: PinDetailServiceProtocol
    private let dateFormatter: DateFormatter = {
        let df = DateFormatter()
        df.dateStyle = .medium
        df.timeStyle = .none
        return df
    }()

    init(photoID: String, service: PinDetailServiceProtocol) {
        self.photoID = photoID
        self.service = service
    }

    // MARK: - Inputs

    func viewDidLoad() {
        transitionTo(.loading)
        Task { [weak self] in
            guard let self else { return }
            do {
                let photo = try await self.service.fetchPhoto(id: self.photoID)
                await MainActor.run { self.handleSuccess(photo: photo) }
            } catch {
                await MainActor.run { self.transitionTo(.error(error.localizedDescription)) }
            }
        }
    }

    // MARK: - Private

    private func handleSuccess(photo: UnsplashPhoto) {
        imageURL = photo.urls.regular
        titleText = photo.description ?? photo.altDescription ?? "Untitled"
        authorName = photo.user.name
        authorAvatarURL = photo.user.profileImage?.medium
        likesText = PhotoCellViewModel.formatLikes(photo.likes)
        dateText = formatDate(photo.createdAt)
        descriptionText = photo.description ?? ""
        exifText = formatExif(photo.exif)
        locationText = formatLocation(photo.location)
        transitionTo(.loaded)
    }

    func formatDate(_ date: Date?) -> String {
        guard let date else { return "" }
        return dateFormatter.string(from: date)
    }

    func formatExif(_ exif: UnsplashExif?) -> String {
        guard let exif else { return "" }
        var parts: [String] = []
        if let make = exif.make, let model = exif.model {
            parts.append("\(make) \(model)")
        } else if let model = exif.model {
            parts.append(model)
        }
        if let aperture = exif.aperture {
            parts.append("f/\(aperture)")
        }
        if let exposure = exif.exposureTime {
            parts.append("\(exposure)s")
        }
        if let iso = exif.iso {
            parts.append("ISO \(iso)")
        }
        return parts.joined(separator: " \u{2022} ")
    }

    func formatLocation(_ location: UnsplashLocation?) -> String {
        guard let location else { return "" }
        let parts = [location.city, location.country].compactMap { $0 }
        if parts.isEmpty, let name = location.name { return name }
        return parts.joined(separator: ", ")
    }

    private func transitionTo(_ newState: DetailState) {
        state = newState
    }
}
