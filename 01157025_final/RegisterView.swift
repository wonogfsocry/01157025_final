//
//  RegisterView.swift
//  01157025_final
//
//  Created by user10 on 2024/12/9.
//
import SwiftUI
import SwiftData

struct RegisterView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var username: String = ""
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var registrationError: String?

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 20) {
                Text("Register")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 3)

                VStack(spacing: 15) {
                    TextField("Username", text: $username)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                        .autocapitalization(.none)

                    SecureField("Password", text: $password)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)

                    SecureField("Confirm Password", text: $confirmPassword)
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(8)
                        .foregroundColor(.white)
                }

                if let error = registrationError {
                    Text(error)
                        .foregroundColor(.red)
                        .font(.caption)
                }

                Button(action: register) {
                    Text("Register")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.blue)
                        .cornerRadius(12)
                }

                Button(action: {
                    dismiss()
                }) {
                    Text("Cancel")
                        .font(.headline)
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.red)
                        .cornerRadius(12)
                }
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(12)
            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
            .padding()
        }
        .navigationBarHidden(true)
    }

    private func register() {
        guard !username.isEmpty, !password.isEmpty else {
            registrationError = "Username and password cannot be empty"
            return
        }
        guard password == confirmPassword else {
            registrationError = "Passwords do not match"
            return
        }
        
        // 使用 FetchDescriptor 查找是否存在相同的用戶名
        let descriptor = FetchDescriptor<User>(
            predicate: #Predicate { $0.username == username }
        )
        let existingUsers = try? modelContext.fetch(descriptor)

        guard existingUsers?.isEmpty == true else {
            registrationError = "Username already exists"
            return
        }
        
        // 新建用戶並插入數據
        let newUser = User(username: username, password: password)
        modelContext.insert(newUser)
        dismiss() // 關閉註冊視圖
    }
}
