import Foundation
import WebKit

struct GameSize: Equatable {
    let width: CGFloat
    let height: CGFloat
}

final class GameViewport {
    private weak var webView: WKWebView?
    private(set) var gameSize: GameSize?

    init(webView: WKWebView) {
        self.webView = webView
    }

    func updateGameSize(width: CGFloat, height: CGFloat) {
        guard width > 0, height > 0 else { return }

        gameSize = GameSize(width: width, height: height)
    }

    func fit(availableSize: CGSize) {
        guard let gameSize,
              gameSize.width > 0,
              gameSize.height > 0,
              availableSize.width > 0,
              availableSize.height > 0
        else { return }

        let scaleX = availableSize.width / gameSize.width
        let scaleY = availableSize.height / gameSize.height
        let scale = min(scaleX, scaleY)

        let javascript = "window.__kancolleSetScale(\(scale));"
        webView?.evaluateJavaScript(javascript)
    }
}
