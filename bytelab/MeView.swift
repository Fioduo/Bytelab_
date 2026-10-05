import SwiftUI

struct MeView: View {
    @State private var loginMode = true
    @State private var user = ""
    @State private var email = ""
    @State private var pw = ""
    @State private var name = ""
    @State private var role = ""
    @State private var msg = ""
    @State private var refresh = false

    private let accent = Color(red: 0.85, green: 0.64, blue: 0.25)
    private let bg = Color(red: 0.05, green: 0.05, blue: 0.06)

    var body: some View {
        Group {
            if API.logged {
                VStack(spacing: 12) {
                    Text(name).font(.title2).foregroundColor(.white)
                    Text(role).font(.subheadline).foregroundColor(accent)
                    Button("退出登录") {
                        API.clearToken()
                        refresh.toggle()
                    }
                    .buttonStyle(.bordered)
                    .tint(.red)
                }
                .padding()
                .onAppear { Task { await loadMe() } }
            } else {
                form
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(bg)
        .navigationTitle("我的")
        .onChange(of: refresh) { _ in }
    }

    private var form: some View {
        Form {
            Section {
                TextField("用户名", text: $user)
                    .textContentType(.username)
                    .autocapitalization(.none)
                if !loginMode {
                    TextField("邮箱（必填）", text: $email)
                        .keyboardType(.emailAddress)
                        .autocapitalization(.none)
                }
                SecureField("密码", text: $pw)
            }
            Section {
                Button(loginMode ? "登录" : "注册") { Task { await submit() } }
                    .buttonStyle(.borderedProminent)
                    .tint(accent)
                Button(loginMode ? "没有账号？去注册" : "已有账号？去登录") {
                    loginMode.toggle()
                }
                .buttonStyle(.plain)
                .foregroundColor(accent)
            }
            if !msg.isEmpty {
                Section { Text(msg).foregroundColor(.red) }
            }
        }
        .background(bg)
    }

    private func submit() async {
        let path = loginMode ? "/api/v1/auth/login" : "/api/v1/auth/register"
        var body: [String: Any] = ["username": user, "password": pw]
        if !loginMode { body["email"] = email }
        do {
            let o = try await API.post(path, body)
            if let d = o["data"] as? [String: Any], let t = d["token"] as? String {
                API.setToken(t)
                msg = ""
                await loadMe()
            } else {
                msg = "用户名或密码错误"
            }
        } catch {
            msg = "操作失败"
        }
    }

    private func loadMe() async {
        if let o = try? await API.get("/api/v1/me"),
           let d = o["data"] as? [String: Any],
           let u = d["user"] as? [String: Any] {
            name = u["name"] as? String ?? ""
            let r = u["role"] as? String ?? ""
            let lv = u["level"] as? Int ?? 0
            role = (r + " · LV\(lv)").trimmingCharacters(in: .whitespaces)
        }
    }
}
