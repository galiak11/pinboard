import Foundation

struct PhotoCellViewModel: Hashable {
    let id: String
    let imageURL: URL
    let aspectRatio: CGFloat
    let title: String
    let authorName: String
    let likesText: String

    init(photo: UnsplashPhoto) {
        self.id = photo.id
        self.imageURL = photo.urls.small
        self.aspectRatio = photo.width > 0
            ? CGFloat(photo.height) / CGFloat(photo.width)
            : 1.0
        self.title = photo.description ?? photo.altDescription ?? ""
        self.authorName = photo.user.name
        self.likesText = Self.formatLikes(photo.likes)
    }

    static func formatLikes(_ count: Int) -> String {
        switch count {
        case 0:
            return "No likes yet"
        case 1:
            return "1 like"
        case 2...999:
            return "\(count) likes"
        default:
            let thousands = Double(count) / 1000.0
            return String(format: "%.1fK likes", thousands)
        }
    }
}
