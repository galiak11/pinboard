import Testing
import Foundation
@testable import PinBoard

@Suite("AppRoute Deep Linking")
struct AppRouteTests {

    @Test func homeRoute_fromURL() {
        let url = URL(string: "pinboard://home")!
        let route = AppRoute(url: url)
        #expect(route == .home)
    }

    @Test func photoDetailRoute_fromURL() {
        let url = URL(string: "pinboard://photo/abc-123")!
        let route = AppRoute(url: url)
        #expect(route == .photoDetail(id: "abc-123"))
    }

    @Test func invalidScheme_returnsNil() {
        let url = URL(string: "https://photo/abc-123")!
        let route = AppRoute(url: url)
        #expect(route == nil)
    }

    @Test func unknownHost_returnsNil() {
        let url = URL(string: "pinboard://settings")!
        let route = AppRoute(url: url)
        #expect(route == nil)
    }

    @Test func photoRoute_withoutID_returnsNil() {
        let url = URL(string: "pinboard://photo")!
        let route = AppRoute(url: url)
        #expect(route == nil)
    }
}
