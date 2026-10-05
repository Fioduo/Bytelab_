import SwiftUI
import WebKit

/// bytelab · iOS WebView 客户端
struct WebView: UIViewRepresentable {
    let url: URL

    func makeUIView(context: Context) -> WKWebView {
        let wv = WKWebView()
        wv.allowsBackForwardNavigationGestures = true
        wv.configuration.mediaTypesRequiringUserActionForPlayback = []
        wv.load(URLRequest(url: url))
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}
}

@main
struct bytelabApp: App {
    var body: some Scene {
        WindowGroup {
            WebView(url: URL(string: "https://bytelab.cc.cd/")!)
                .edgesIgnoringSafeArea(.all)
        }
    }
}
