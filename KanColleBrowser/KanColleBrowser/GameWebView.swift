import SwiftUI
import WebKit

struct GameWebView: UIViewRepresentable {
    let url: URL

    func makeCoordinator() -> Coordinator {
        Coordinator()
    }

    func makeUIView(context: Context) -> WKWebView {
        let configuration = WKWebViewConfiguration()
        let controller = WKUserContentController()

        controller.add(context.coordinator, name: "gameSize")
        configuration.userContentController = controller
        configuration.websiteDataStore = .default()

        let webView = WKWebView(frame: .zero, configuration: configuration)
        webView.navigationDelegate = context.coordinator
        webView.scrollView.isScrollEnabled = false
        webView.scrollView.bounces = false

        context.coordinator.attach(webView: webView)
        context.coordinator.installViewportScript()

        // Cookie installation must complete before navigation.
        context.coordinator.installCookiesAndLoad(url: url)

        return webView
    }

    func updateUIView(_ webView: WKWebView, context: Context) {
        context.coordinator.updateSize(webView.bounds.size)
    }

    static func dismantleUIView(
        _ webView: WKWebView,
        coordinator: Coordinator
    ) {
        webView.configuration.userContentController
            .removeScriptMessageHandler(forName: "gameSize")
    }

    final class Coordinator: NSObject, WKScriptMessageHandler, WKNavigationDelegate {
        private weak var webView: WKWebView?
        private var viewport: GameViewport?
        private var availableSize: CGSize = .zero

        func attach(webView: WKWebView) {
            self.webView = webView
            self.viewport = GameViewport(webView: webView)
        }

        func updateSize(_ size: CGSize) {
            availableSize = size
            viewport?.fit(availableSize: size)
        }

        func installCookiesAndLoad(url: URL) {
            guard let webView else { return }

            let manager = DMMCookieManager(
                store: webView.configuration.websiteDataStore.httpCookieStore
            )

            manager.installRegionCookies { [weak self] error in
                guard let self, let webView else { return }

                if let error {
                    print("DMM cookie error: \(error)")
                }

                webView.load(URLRequest(url: url))
            }
        }

        func userContentController(
            _ userContentController: WKUserContentController,
            didReceive message: WKScriptMessage
        ) {
            guard message.name == "gameSize",
                  let body = message.body as? [String: Any],
                  let width = body["width"] as? Double,
                  let height = body["height"] as? Double
            else { return }

            viewport?.updateGameSize(width: width, height: height)
            viewport?.fit(availableSize: availableSize)
        }

        func installViewportScript() {
            let source = """
            (() => {
                window.__kancolleSetScale = function(scale) {
                    document.documentElement.style.setProperty(
                        '--kancolle-scale',
                        String(scale)
                    );

                    // Placeholder: the actual game element selector and
                    // scaling method should be finalized after inspecting
                    // the current KanColle DOM.
                    document.documentElement.style.setProperty(
                        '--kancolle-scale-value',
                        String(scale)
                    );
                };

                function reportGameSize(element) {
                    const rect = element.getBoundingClientRect();

                    window.webkit.messageHandlers.gameSize.postMessage({
                        width: rect.width,
                        height: rect.height
                    });
                }

                function observeGame(element) {
                    reportGameSize(element);

                    const observer = new ResizeObserver(() => {
                        reportGameSize(element);
                    });

                    observer.observe(element);
                }

                function findGame() {
                    // TODO: replace with the actual current KanColle
                    // game container selector after DOM inspection.
                    return document.querySelector('#game');
                }

                function start() {
                    const game = findGame();

                    if (game) {
                        observeGame(game);
                        return;
                    }

                    setTimeout(start, 500);
                }

                start();
            })();
            """

            let script = WKUserScript(
                source: source,
                injectionTime: .atDocumentStart,
                forMainFrameOnly: true
            )

            webView?.configuration.userContentController
                .addUserScript(script)
        }
    }
}
