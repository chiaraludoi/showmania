import SwiftUI
import WebKit

@main
struct ShowsApp: App {
    var body: some Scene {
        WindowGroup { BrowserScreen() }
    }
}

struct BrowserScreen: View {
    @State private var browser = Browser()
    var body: some View {
        VStack(spacing: 0) {
            WebContent(browser: browser)
            HStack {
                Button { browser.view.goBack() } label: {
                    Label("Back", systemImage: "chevron.backward")
                }
                Spacer()
                Button { browser.openHome() } label: {
                    Label("Home", systemImage: "house")
                }
                Spacer()
                Button { browser.view.reload() } label: {
                    Label("Reload", systemImage: "arrow.clockwise")
                }
            }
            .labelStyle(.iconOnly)
            .padding()
        }
    }
}

final class Browser: NSObject, WKUIDelegate {
    let view: WKWebView
    private let home = URL(string: "https://www.1shows.org/")!

    override init() {
        let configuration = WKWebViewConfiguration()
        configuration.allowsInlineMediaPlayback = true
        view = WKWebView(frame: .zero, configuration: configuration)
        super.init()
        view.uiDelegate = self
        openHome()
    }

    func openHome() {
        view.load(URLRequest(url: home))
    }

    func webView(
        _ webView: WKWebView,
        createWebViewWith configuration: WKWebViewConfiguration,
        for navigationAction: WKNavigationAction,
        windowFeatures: WKWindowFeatures
    ) -> WKWebView? {
        if navigationAction.targetFrame == nil,
           navigationAction.navigationType == .linkActivated,
           let scheme = navigationAction.request.url?.scheme,
           ["http", "https"].contains(scheme) {
            webView.load(navigationAction.request)
        }
        return nil
    }
}

struct WebContent: UIViewRepresentable {
    let browser: Browser
    func makeUIView(context: Context) -> WKWebView { browser.view }
    func updateUIView(_ uiView: WKWebView, context: Context) {}
}
