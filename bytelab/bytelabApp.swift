import SwiftUI
import WebKit

@main
struct bytelabApp: App {
    var body: some Scene {
        WindowGroup {
            HybridRootView()
                .preferredColorScheme(.dark)
        }
    }
}

/// 混合壳：原生顶栏/加载提示 + WKWebView 承载整个官网，全功能、不白屏、自适应异形屏。
struct HybridRootView: View {
    @StateObject private var model = WebModel()
    @State private var canGoBack = false
    @State private var canGoForward = false

    private let accent = Color(red: 0.85, green: 0.64, blue: 0.25)

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.06).ignoresSafeArea()

            WebShell(model: model,
                     canGoBack: $canGoBack,
                     canGoForward: $canGoForward)
                .ignoresSafeArea()

            // 原生加载提示
            if model.loading {
                VStack(spacing: 14) {
                    ProgressView()
                        .progressViewStyle(CircularProgressViewStyle(tint: accent))
                    Text("正在加载…")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.88))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.05, green: 0.05, blue: 0.06))
            }

            // 错误兜底：不白屏
            if model.failed {
                VStack(spacing: 16) {
                    Text("加载失败，请检查网络")
                        .font(.system(size: 14))
                        .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.88))
                    Button("重试") {
                        model.failed = false
                        model.reload()
                    }
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(Color(red: 0.05, green: 0.05, blue: 0.06))
                    .padding(.horizontal, 22).padding(.vertical, 8)
                    .background(accent)
                    .cornerRadius(8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(red: 0.05, green: 0.05, blue: 0.06))
            }
        }
        // 原生顶栏（安全区内自适应，避开刘海）
        .safeAreaInset(edge: .top, spacing: 0) {
            HStack(spacing: 10) {
                Image(systemName: "play.square.stack.fill")
                    .foregroundColor(accent)
                Text("bytelab")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(red: 0.9, green: 0.9, blue: 0.88))
                Spacer()
                btn("chevron.left", !canGoBack) { model.goBack() }
                btn("chevron.right", !canGoForward) { model.goForward() }
                btn("arrow.clockwise", false) { model.reload() }
                btn("xmark", false) { model.exitFullscreenOrHome() }
            }
            .padding(.horizontal, 12).padding(.vertical, 6)
            .background(Color(red: 0.086, green: 0.086, blue: 0.11))
        }
        .onReceive(model.$didUpdate) { _ in
            canGoBack = model.web?.canGoBack ?? false
            canGoForward = model.web?.canGoForward ?? false
        }
    }

    private func btn(_ icon: String, _ off: Bool, _ act: @escaping () -> Void) -> some View {
        Button(action: act) {
            Image(systemName: icon)
                .font(.system(size: 15, weight: .semibold))
                .foregroundColor(off ? Color.gray.opacity(0.4) : Color(red: 0.9, green: 0.9, blue: 0.88))
                .frame(width: 30, height: 30)
        }
        .disabled(off)
    }
}

final class WebModel: NSObject, ObservableObject, WKNavigationDelegate {
    @Published var loading = false
    @Published var failed = false
    @Published var didUpdate = 0
    var web: WKWebView?
    private var initialLoadDone = false

    func makeWeb() -> WKWebView {
        let cfg = WKWebViewConfiguration()
        cfg.allowsInlineMediaPlayback = true
        cfg.mediaTypesRequiringUserActionForPlayback = []
        let w = WKWebView(frame: .zero, configuration: cfg)
        w.navigationDelegate = self
        w.allowsBackForwardNavigationGestures = true
        web = w
        return w
    }

    func load() {
        if let u = URL(string: "https://bytelab.cc.cd") {
            web?.load(URLRequest(url: u))
        }
    }
    func reload() { web?.reload() }
    func goBack() { web?.goBack() }
    func goForward() { web?.goForward() }
    func exitFullscreenOrHome() {
        web?.evaluateJavaScript("if(document.fullscreenElement){document.exitFullscreen()}else{location.href='/'}",
                                completionHandler: nil)
    }

    func webView(_ webView: WKWebView, didStartProvisionalNavigation navigation: WKNavigation!) {
        loading = true; failed = false
    }
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        loading = false; didUpdate += 1
    }
    func webView(_ webView: WKWebView, didFail navigation: WKNavigation!, withError error: Error) {
        loading = false; failed = true
    }
    func webView(_ webView: WKWebView, didFailProvisionalNavigation navigation: WKNavigation!, withError error: Error) {
        loading = false; failed = true
    }
}

struct WebShell: UIViewRepresentable {
    let model: WebModel
    @Binding var canGoBack: Bool
    @Binding var canGoForward: Bool

    func makeUIView(context: Context) -> WKWebView {
        let w = model.makeWeb()
        model.load()
        return w
    }
    func updateUIView(_ uiView: WKWebView, context: Context) {
        canGoBack = uiView.canGoBack
        canGoForward = uiView.canGoForward
    }
}
