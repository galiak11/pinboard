import Foundation

struct UnsplashUser: Decodable, Equatable {
    let id: String
    let username: String
    let name: String
    let profileImage: ProfileImageURLs?

    struct ProfileImageURLs: Decodable, Equatable {
        let small: URL
        let medium: URL
        let large: URL
    }
}
