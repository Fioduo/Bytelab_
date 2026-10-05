import Foundation

struct Video: Identifiable {
    let id: String
    let title: String
    let uploader: String
    let cat: String
    let duration: Int
    let views: Int

    init(_ d: [String: Any]) {
        id = d["id"] as? String ?? ""
        title = d["title"] as? String ?? ""
        uploader = d["uploader"] as? String ?? ""
        cat = d["cat"] as? String ?? ""
        duration = d["duration"] as? Int ?? 0
        views = d["views"] as? Int ?? 0
    }

    var durationText: String {
        if duration <= 0 { return "--:--" }
        return String(format: "%02d:%02d", duration / 60, duration % 60)
    }
    var viewsText: String {
        if views >= 10000 { return String(format: "%.1f万", Double(views) / 10000) }
        return "\(views)"
    }
}
