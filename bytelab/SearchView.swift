import SwiftUI

struct SearchView: View {
    @State private var q = ""
    @State private var results: [Video] = []
    @State private var searched = false

    var body: some View {
        VStack(spacing: 0) {
            HStack {
                TextField("搜索视频 / #标签 / UP主", text: $q)
                    .textFieldStyle(.roundedBorder)
                Button {
                    Task { await search() }
                } label: {
                    Text("搜索").fontWeight(.semibold)
                }
                .buttonStyle(.borderedProminent)
                .tint(Color(red: 0.85, green: 0.64, blue: 0.25))
            }
            .padding()

            if searched {
                List(results) { v in
                    NavigationLink(destination: VideoPlayerView(vid: v.id)) {
                        VStack(alignment: .leading, spacing: 4) {
                            Text(v.title).font(.headline).foregroundColor(.white).lineLimit(2)
                            Text("\(v.uploader) · \(v.cat) · \(v.viewsText)播放")
                                .font(.caption).foregroundColor(.gray)
                        }.padding(.vertical, 4)
                    }
                }
                .listStyle(.plain)
                .background(Color(red: 0.05, green: 0.05, blue: 0.06))
            } else {
                Spacer()
                Text("输入关键词搜索").foregroundColor(.gray)
                Spacer()
            }
        }
        .background(Color(red: 0.05, green: 0.05, blue: 0.06))
        .navigationTitle("搜索")
    }

    private func search() async {
        guard !q.isEmpty else { return }
        let enc = q.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        if let o = try? await API.get("/api/v1/search?q=\(enc)"),
           let d = o["data"] as? [String: Any],
           let a = d["videos"] as? [[String: Any]] {
            results = a.map { Video($0) }
            searched = true
        }
    }
}
