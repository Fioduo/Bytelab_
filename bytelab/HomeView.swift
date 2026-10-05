import SwiftUI

struct HomeView: View {
    @State private var cats: [String] = []
    @State private var curCat = ""
    @State private var videos: [Video] = []
    @State private var loading = true

    private let bg = Color(red: 0.05, green: 0.05, blue: 0.06)
    private let card = Color(red: 0.09, green: 0.09, blue: 0.10)
    private let accent = Color(red: 0.85, green: 0.64, blue: 0.25)

    var body: some View {
        VStack(spacing: 0) {
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    chip("全部", "")
                    ForEach(cats, id: \.self) { c in chip(c, c) }
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
            }
            .background(card)

            if videos.isEmpty && loading {
                Spacer()
                ProgressView()
                Spacer()
            } else {
                List(videos) { v in
                    NavigationLink(destination: VideoPlayerView(vid: v.id)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(v.title)
                                .font(.headline)
                                .foregroundColor(.white)
                                .lineLimit(2)
                            Text("\(v.uploader) · \(v.cat) · \(v.viewsText)播放 · \(v.durationText)")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
                .background(bg)
            }
        }
        .background(bg)
        .navigationTitle("bytelab")
        .task { await loadCats(); await loadFeed() }
    }

    private func chip(_ label: String, _ tag: String) -> some View {
        Button {
            curCat = tag
            Task { await loadFeed() }
        } label: {
            Text(label)
                .font(.subheadline)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(curCat == tag ? accent : Color(red: 0.12, green: 0.12, blue: 0.14))
                .foregroundColor(curCat == tag ? .black : .white)
                .cornerRadius(6)
        }
        .buttonStyle(.plain)
    }

    private func loadCats() async {
        if let o = try? await API.get("/api/v1/categories"),
           let d = o["data"] as? [String: Any],
           let a = d["cats"] as? [String] {
            cats = a
        }
    }

    private func loadFeed() async {
        loading = true
        var q = curCat.isEmpty ? "" : "&cat=" + (curCat.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? "")
        if let o = try? await API.get("/api/v1/feed?page=1\(q)"),
           let d = o["data"] as? [String: Any],
           let a = d["videos"] as? [[String: Any]] {
            videos = a.map { Video($0) }
        }
        loading = false
    }
}
