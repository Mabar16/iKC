import Foundation
import WebKit

/// Installs the DMM region cookie before the first relevant navigation.
///
/// The cookie value/domain/path should be verified against the current
/// KC3Kai implementation before shipping. This initial project uses the
/// documented ckcy=1 approach as our working baseline.
final class DMMCookieManager {
    private let store: WKHTTPCookieStore

    init(store: WKHTTPCookieStore) {
        self.store = store
    }

    func installRegionCookies(
        completion: @escaping (Error?) -> Void
    ) {
        let cookies = [
            makeCookie(name: "ckcy", value: "1", domain: ".dmm.com", path: "/"),
            makeCookie(name: "ckcy", value: "1", domain: ".dmm.com", path: "/netgame")
        ].compactMap { $0 }

        guard !cookies.isEmpty else {
            completion(NSError(
                domain: "DMMCookieManager",
                code: 1,
                userInfo: [NSLocalizedDescriptionKey: "Unable to create DMM cookies."]
            ))
            return
        }

        let group = DispatchGroup()

        for cookie in cookies {
            group.enter()
            store.setCookie(cookie) {
                group.leave()
            }
        }

        group.notify(queue: .main) {
            completion(nil)
        }
    }

    func getCKCY(completion: @escaping (HTTPCookie?) -> Void) {
        store.getAllCookies { cookies in
            completion(cookies.first {
                $0.name.caseInsensitiveCompare("ckcy") == .orderedSame
            })
        }
    }

    private func makeCookie(
        name: String,
        value: String,
        domain: String,
        path: String
    ) -> HTTPCookie? {
        HTTPCookie(properties: [
            .domain: domain,
            .path: path,
            .name: name,
            .value: value,
            .secure: true
        ])
    }
}
