import SwiftUI
import WebKit

/// bytelab · iOS WebView 客户端
/// 修正：视频内联播放、加载失败重试、进度条。
struct WebView: UIViewRepresentable {
    let url: URL
    @Binding var progress: Double
    @Binding var failed: Bool

    func makeCoordinator() -> Coordinator { Coordinator(self) }

    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        config.mediaTypesRequiringUserActionForPlayback = []
        config.mediaPlaybackRequiresUserAction = false
        config.mediaPlaybackAllowsAirPlay = true
        let wv = WKWebView(frame: .zero, configuration: config)
        wv.allowsBackForwardNavigationGestures = true
        wv.navigationDelegate = context.coordinator
        wv.addObserver(context.coordinator, forKeyPath: "estimatedProgress",
                        options: .new, context: nil)
        wv.load(URLRequest(url: url))
        return wv
    }

    func updateUIView(_ uiView: WKWebView, context: Context) {}

    static func dismantleUIView(_ uiView: WKWebView, coordinator: Coordinator) {
        uiView.removeObserver(coordinator, forKeyPath: "estimatedProgress")
    }

    class Coordinator: NSObject, WKNavigationDelegate {
        var parent: WebView
        init(_ p: WebView) { parent = p }

        func webView(_ webView: WKWebView,
                     didFail navigation: WKNavigation!, withError error: Error) {
            parent.failed = true
        }
        func webView(_ webView: WKWebView,
                     didFailProvisionalNavigation navigation: WKNavigation!,
                     withError error: Error) {
            parent.failed = true
        }
        func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
            parent.failed = false
        }
        override func observeValue(forKeyPath keyPath: String?, of object: Any?,
                                   change: [NSKeyValueChangeKey: Any]?,
                                   context: UnsafeMutableRawPointer?) {
            if keyPath == "estimatedProgress" {
                parent.progress = (change?[.newKey] as? Double) ?? 0
            }
        }
    }
}

@main
struct bytelabApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var progress: Double = 0
    @State private var failed = false
    @State private var refreshID = UUID()

    var body: some View {
        ZStack(alignment: .top) {
            WebView(url: URL(string: "https://bytelab.cc.cd/")!,
                    progress: $progress, failed: $failed)
                .edgesIgnoringSafeArea(.all)

            if failed {
                VStack(spacing: 12) {
                    Text("网络连接失败").font(.headline).foregroundColor(.white)
                    Button("重试") {
                        failed = false
                        refreshID = UUID()
                    }
                    .padding(.horizontal, 24).padding(.vertical, 10)
                    .background(Color.orange).foregroundColor(.black)
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black.opacity(0.85))
            } else if progress > 0 && progress < 1 {
                ProgressView(value: progress)
                    .progressViewStyle(LinearProgressViewStyle())
                    .tint(Color.orange)
            }
        }
        .id(refreshID)
    }
}
