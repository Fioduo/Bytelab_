import SwiftUI

@main
struct bytelabApp: App {
    var body: some Scene {
        WindowGroup {
            RootView()
                .preferredColorScheme(.dark)
        }
    }
}

struct RootView: View {
    @State private var tab = 0
    private let accent = Color(red: 0.85, green: 0.64, blue: 0.25)
    private let bg = Color(red: 0.05, green: 0.05, blue: 0.06)

    var body: some View {
        TabView(selection: $tab) {
            NavigationView { HomeView() }
                .tabItem { Label("首页", systemImage: "house.fill") }.tag(0)
            NavigationView { SearchView() }
                .tabItem { Label("搜索", systemImage: "magnifyingglass") }.tag(1)
            NavigationView { MeView() }
                .tabItem { Label("我的", systemImage: "person.fill") }.tag(2)
        }
        .accentColor(accent)
        .preferredColorScheme(.dark)
    }
}
