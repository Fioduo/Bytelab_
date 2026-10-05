import Foundation

/// bytelab iOS 原生 API 客户端
struct API {
    static let base = "https://bytelab.cc.cd"

    static var token: String { UserDefaults.standard.string(forKey: "token") ?? "" }
    static var logged: Bool { !token.isEmpty }
    static func setToken(_ t: String) { UserDefaults.standard.set(t, forKey: "token") }
    static func clearToken() { UserDefaults.standard.removeObject(forKey: "token") }

    static func request(_ path: String, method: String = "GET",
                        body: [String: Any]? = nil) async throws -> [String: Any] {
        var req = URLRequest(url: URL(string: base + path)!)
        req.httpMethod = method
        req.timeoutInterval = 30
        if let body = body {
            req.httpBody = try JSONSerialization.data(withJSONObject: body)
            req.setValue("application/json; charset=utf-8", forHTTPHeaderField: "Content-Type")
        }
        if logged {
            req.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        let (data, resp) = try await URLSession.shared.data(for: req)
        guard let http = resp as? HTTPURLResponse, (200..<300).contains(http.statusCode) else {
            throw NSError(domain: "api", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "请求失败"])
        }
        if let obj = try? JSONSerialization.jsonObject(with: data) as? [String: Any] {
            return obj
        }
        return [:]
    }

    static func get(_ path: String) async throws -> [String: Any] {
        try await request(path)
    }
    static func post(_ path: String, _ body: [String: Any]? = nil) async throws -> [String: Any] {
        try await request(path, method: "POST", body: body)
    }
}
