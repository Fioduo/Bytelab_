import SwiftUI
import AVKit

struct VideoPlayerView: View {
    let vid: String
    @State private var play = ""
    @State private var title = ""
    @State private var meta = ""
    @State private var liked = false
    @State private var likes = 0
    @State private var showComment = false
    @State private var commentText = ""
    @State private var comments: [[String: Any]] = []

    var body: some View {
        VStack(spacing: 0) {
            if !play.isEmpty {
                VideoPlayer(player: AVPlayer(url: URL(string: play)!))
                    .frame(maxWidth: .infinity)
                    .frame(height: 260)
            } else {
                ZStack {
                    Color.black
                    ProgressView()
                }
                .frame(height: 260)
                .task { await load() }
            }

            ScrollView {
                VStack(alignment: .leading, spacing: 8) {
                    Text(title).font(.headline).foregroundColor(.white)
                    Text(meta).font(.caption).foregroundColor(.gray)

                    HStack(spacing: 16) {
                        Button {
                            Task { await like() }
                        } label: {
                            Label("\(likes) 点赞", systemImage: "hand.thumbsup.fill")
                                .font(.subheadline)
                        }
                        .buttonStyle(.bordered)
                        .tint(Color(red: 0.85, green: 0.64, blue: 0.25))

                        Button {
                            showComment.toggle()
                        } label: {
                            Label("评论", systemImage: "bubble.left.fill")
                                .font(.subheadline)
                        }
                        .buttonStyle(.bordered)
                        .tint(.gray)
                    }

                    if showComment {
                        HStack {
                            TextField("发一条友善的评论…", text: $commentText)
                                .textFieldStyle(.roundedBorder)
                            Button("发送") { Task { await postComment() } }
                                .buttonStyle(.borderedProminent)
                                .tint(Color(red: 0.85, green: 0.64, blue: 0.25))
                        }
                        .padding(.vertical, 4)
                    }

                    Divider()
                    Text("评论 \(comments.count)").font(.subheadline).foregroundColor(.white)
                    ForEach(comments, id: \.self) { c in
                        VStack(alignment: .leading, spacing: 2) {
                            Text((c["user"] as? String ?? "") + "：")
                                .font(.caption)
                                .foregroundColor(Color(red: 0.85, green: 0.64, blue: 0.25))
                            Text(c["text"] as? String ?? "")
                                .font(.body)
                                .foregroundColor(.white)
                        }
                        .padding(.vertical, 4)
                    }
                }
                .padding()
            }
        }
        .background(Color(red: 0.05, green: 0.05, blue: 0.06))
        .navigationTitle("播放")
        .navigationBarTitleDisplayMode(.inline)
        .task { await loadComments() }
    }

    private func load() async {
        if let o = try? await API.get("/api/v1/video/\(vid)"),
           let d = o["data"] as? [String: Any] {
            play = d["play_url"] as? String ?? ""
            title = d["title"] as? String ?? ""
            likes = d["likes"] as? Int ?? 0
            let up = d["uploader"] as? String ?? ""
            let dur = d["duration"] as? Int ?? 0
            meta = "\(up) · \(d["views"] as? Int ?? 0)播放 · \(dur / 60):\(String(format: "%02d", dur % 60))"
        }
    }

    private func loadComments() async {
        if let o = try? await API.get("/api/v1/video/\(vid)/comments"),
           let d = o["data"] as? [String: Any],
           let a = d["data"] as? [[String: Any]] {
            comments = a
        }
    }

    private func like() async {
        guard API.logged else { return }
        if let o = try? await API.post("/api/v1/video/\(vid)/like"),
           let d = o["data"] as? [String: Any] {
            likes = d["likes"] as? Int ?? likes
        }
    }

    private func postComment() async {
        guard API.logged, !commentText.isEmpty else { return }
        _ = try? await API.post("/api/v1/video/\(vid)/comments", ["text": commentText])
        commentText = ""
        await loadComments()
    }
}
