//
//  LoginView.swift
//  01157025_final
//
//  Created by user10 on 2024/12/9.
//

import SwiftUI
import SwiftData

@Model
class User {
    @Attribute var id: UUID
    @Attribute var username: String
    @Attribute var password: String
    @Relationship var activityRecords: [ActivityRecord] = []
    @Relationship var goals: [Goal] = []
    
    init(username: String, password: String) {
        self.id = UUID()
        self.username = username
        self.password = password
    }
}

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var currentUser: User?
    
    @Environment(\.modelContext) private var modelContext
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var keepLoggedIn: Bool = false // 是否保持登入
    @State private var showRegisterView = false
    @State private var loginError: String?
    
    var body: some View {
        NavigationView {
            ZStack {
                // 背景漸變
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.7), Color.purple.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    // 標題
                    VStack {
                        Text("Welcome Back!")
                            .font(.system(size: 32, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("Login to continue")
                            .font(.subheadline)
                            .foregroundColor(.white.opacity(0.7))
                    }
                    .padding(.bottom, 20)
                    
                    // 登入表單
                    VStack(spacing: 15) {
                        TextField("Username", text: $username)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                        
                        SecureField("Password", text: $password)
                            .padding()
                            .background(Color.white.opacity(0.9))
                            .cornerRadius(12)
                            .shadow(color: .gray.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                    
                    // 保持登入勾選框
                    Toggle("Keep me logged in", isOn: $keepLoggedIn)
                        .foregroundColor(.white)
                        .padding(.horizontal)
                    
                    // 登錄錯誤訊息
                    if let error = loginError {
                        Text(error)
                            .foregroundColor(.red)
                            .font(.caption)
                            .padding(.top, 5)
                    }
                    
                    // 登錄按鈕
                    Button(action: {
                        login()
                    }) {
                        Text("Login")
                            .font(.headline)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.blue)
                            .cornerRadius(12)
                            .shadow(color: .blue.opacity(0.3), radius: 5, x: 0, y: 3)
                    }
                    .padding(.horizontal)
                    
                    // 註冊按鈕
                    Button(action: {
                        showRegisterView = true
                    }) {
                        HStack {
                            Text("Don't have an account?")
                                .foregroundColor(.white.opacity(0.7))
                            Text("Register")
                                .fontWeight(.bold)
                                .foregroundColor(.yellow)
                        }
                    }
                    .padding(.top, 10)
                }
                .padding()
            }
            .sheet(isPresented: $showRegisterView) {
                RegisterView()
                .presentationDetents([.fraction(0.7)]) // 控制尺寸
                .presentationDragIndicator(.visible) // 顯示拖動指示器
            }
            .onAppear {
                checkLastLogin() // 檢查是否有保持登入的使用者
            }
        }
    }
    
    // 登錄邏輯
    private func login() {
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.username == username && $0.password == password }
        )
        
        do {
            let users = try modelContext.fetch(descriptor)
            if let user = users.first {
                currentUser = user
                isLoggedIn = true
                
                // 如果選擇保持登入，保存用戶資訊到 UserDefaults
                if keepLoggedIn {
                    saveLastLogin(user: user)
                } else {
                    clearLastLogin()
                }
            } else {
                loginError = "Invalid username or password"
            }
        } catch {
            loginError = "Failed to fetch users: \(error.localizedDescription)"
        }
    }
    
    // 檢查是否有保持登入的使用者
    private func checkLastLogin() {
        if let savedUsername = UserDefaults.standard.string(forKey: "lastLoggedInUsername"),
           let savedPassword = UserDefaults.standard.string(forKey: "lastLoggedInPassword") {
            username = savedUsername
            password = savedPassword
            keepLoggedIn = true
            login() // 自動嘗試登入
        }
    }
    
    // 保存使用者登入資訊
    private func saveLastLogin(user: User) {
        UserDefaults.standard.set(user.username, forKey: "lastLoggedInUsername")
        UserDefaults.standard.set(user.password, forKey: "lastLoggedInPassword")
    }
    
    // 清除保存的使用者資訊
    private func clearLastLogin() {
        UserDefaults.standard.removeObject(forKey: "lastLoggedInUsername")
        UserDefaults.standard.removeObject(forKey: "lastLoggedInPassword")
    }
}
