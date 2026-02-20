import Foundation

/// Represents a navigable destination in the app.
/// Used for deep linking via URL schemes and programmatic navigation.
///
/// URL scheme: `pinboard://`
/// - `pinboard://home` → Home feed
/// - `pinboard://photo/<id>` → Photo detail
enum AppRoute: Equatable {
    case home
    case photoDetail(id: String)

    init?(url: URL) {
        guard url.scheme == "pinboard" else { return nil }
        switch url.host {
        case "home":
            self = .home
        case "photo":
            let pathID = url.pathComponents.dropFirst().first
            guard let id = pathID, !id.isEmpty else { return nil }
            self = .photoDetail(id: id)
        default:
            return nil
        }
    }
}
