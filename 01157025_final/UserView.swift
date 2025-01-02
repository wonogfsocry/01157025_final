//
//  UserView.swift
//  01157025_final
//
//  Created by user10 on 2024/12/23.
//
import SwiftUI

struct UserSettingsView: View {
    var user: User
    @State private var isImagePickerPresented = false
    @State private var isActionSheetPresented = false
    @State private var profileImage: UIImage? = nil
    @State private var contactNumber: String = ""
    @State private var signature: String = ""
    @State private var region: String = ""
    @State private var isEditingPassword = false
    @State private var tempPassword = ""
    @State private var newPassword = ""
    @State private var confirmPassword = ""
    @State private var gender = "Not Specified"
    @State private var birthday = Date()
    @State private var selectedRegion: String = "Taiwan"
    @Environment(\.dismiss) private var dismiss
    @Binding var isLoggedIn: Bool
    @State private var errorMessage: String? = nil
    @State private var isEditingContactNumber = false
    @State private var editingContactNumber: String = ""
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    @State private var selectedCity: String = "Taipei"
    
    let regions = [
        "United States", "Canada", "United Kingdom", "Australia", "Germany",
        "France", "Japan", "South Korea", "China", "India", "Taiwan"
    ]
    
    let regionCities: [String: [String]] = [
            "Taiwan": ["Taipei", "Taichung", "Kaohsiung"],
            "United States": ["New York", "Los Angeles", "Chicago"],
            "Canada": ["Toronto", "Vancouver", "Montreal"],
            "United Kingdom": ["London", "Manchester", "Edinburgh"],
            "Australia": ["Sydney", "Melbourne", "Brisbane"],
            "Germany": ["Berlin", "Munich", "Frankfurt"],
            "France": ["Paris", "Lyon", "Marseille"],
            "Japan": ["Tokyo", "Osaka", "Kyoto"],
            "South Korea": ["Seoul", "Busan", "Incheon"],
            "China": ["Beijing", "Shanghai", "Guangzhou"],
            "India": ["Mumbai", "Delhi", "Bangalore"]
        ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // 大头照
                        VStack {
                            ZStack {
                                Circle()
                                    .fill(Color.white.opacity(0.3))
                                    .frame(width: 120, height: 120)
                                
                                if let image = profileImage {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(width: 120, height: 120)
                                        .clipShape(Circle())
                                } else {
                                    Image(systemName: "person.crop.circle.fill")
                                        .resizable()
                                        .scaledToFit()
                                        .frame(width: 120, height: 120)
                                        .foregroundColor(.white)
                                }
                            }
                            .onTapGesture {
                                isActionSheetPresented = true
                            }
                            .actionSheet(isPresented: $isActionSheetPresented) {
                                ActionSheet(
                                    title: Text("Profile Picture"),
                                    buttons: [
                                        .default(Text("Modify Photo")) { isImagePickerPresented = true },
                                        .destructive(Text("Remove Photo")) { profileImage = nil },
                                        .cancel()
                                    ]
                                )
                            }
                            .sheet(isPresented: $isImagePickerPresented) {
                                ImagePicker(image: $profileImage)
                            }
                            
                            Text(user.username)
                                .font(.system(size: 24, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                                .padding(.top, 10)
                        }
                        
                        // 使用者資訊
                        VStack(spacing: 15) {
                            HStack {
                                Text("Gender:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Picker("Gender", selection: $gender) {
                                    Text("Not Specified").tag("Not Specified")
                                    Text("Male").tag("Male")
                                    Text("Female").tag("Female")
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            
                            HStack {
                                Text("Birthday:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                DatePicker("", selection: $birthday, displayedComponents: .date)
                                    .labelsHidden()
                            }
                            
                            HStack {
                                Text("Contact Number:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                if isEditingContactNumber {
                                    HStack {
                                        TextField("Enter phone number", text: $editingContactNumber)
                                            .keyboardType(.phonePad)
                                            .padding()
                                            .background(Color.white.opacity(0.2))
                                            .cornerRadius(8)
                                        
                                        Button(action: {
                                            // 取消更改，恢复原值
                                            editingContactNumber = contactNumber
                                            isEditingContactNumber = false
                                        }) {
                                            Text("Cancel")
                                                .font(.caption)
                                                .foregroundColor(.red)
                                        }
                                        
                                        Button(action: {
                                            // 确认更改
                                            contactNumber = editingContactNumber
                                            isEditingContactNumber = false
                                        }) {
                                            Text("Save")
                                                .font(.caption)
                                                .foregroundColor(.blue)
                                        }
                                    }
                                } else {
                                    Text(contactNumber.isEmpty ? "No contact number" : contactNumber)
                                        .foregroundColor(.white)
                                        .onTapGesture {
                                            // 进入编辑模式
                                            editingContactNumber = contactNumber
                                            isEditingContactNumber = true
                                        }
                                }
                            }
                            
                            HStack {
                                Text("Region:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Picker("Select Region", selection: $selectedRegion) {
                                    ForEach(regions, id: \.self) { region in
                                        Text(region).tag(region)
                                    }
                                }
                                .pickerStyle(MenuPickerStyle())
                            }
                            HStack {
                                Text("Select City:")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Picker("Select City", selection: $selectedCity) {
                                    ForEach(regionCities[selectedRegion] ?? [], id: \.self) { city in
                                        Text(city).tag(city)
                                    }
                                }         
                                .pickerStyle(MenuPickerStyle())
                                .onChange(of: selectedCity) { newCity in
                                    weatherViewModel.city = newCity
                                    weatherViewModel.fetchWeather()
                                }
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                        
                        // 更改密碼功能
                        if isEditingPassword {
                            VStack(spacing: 15) {
                                SecureField("Current Password", text: $tempPassword)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                                
                                SecureField("New Password", text: $newPassword)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                                
                                SecureField("Confirm New Password", text: $confirmPassword)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(8)
                                
                                if let error = errorMessage {
                                    Text(error)
                                        .foregroundColor(.red)
                                        .font(.caption)
                                }
                                
                                Button(action: updatePassword) {
                                    Text("Update Password")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding()
                                        .frame(maxWidth: .infinity)
                                        .background(Color.blue)
                                        .cornerRadius(12)
                                }
                            }
                            .padding()
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                        }
                        
                        Button(action: {
                            tempPassword = ""
                            newPassword = ""
                            confirmPassword = "" 
                            isEditingPassword.toggle()
                            errorMessage = nil
                        }) {
                            Text(isEditingPassword ? "Cancel Password Change" : "Change Password")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(isEditingPassword ? Color.yellow.opacity(0.8) : Color.blue)
                                .cornerRadius(12)
                        }
                        .padding(.top, 20)
                        
                        // 登出按鈕
                        Button(action: logout) {
                            Text("Log Out")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(Color.red)
                                .cornerRadius(12)
                        }
                    }
                    .padding(3)
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("User Setting")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                }
            }
            .onAppear {
                selectedCity = weatherViewModel.city
            }
        }
    }
    
    private func logout() {
        clearLastLogin()
        isLoggedIn = false
    }
    
    private func clearLastLogin() {
        UserDefaults.standard.removeObject(forKey: "lastLoggedInUsername")
        UserDefaults.standard.removeObject(forKey: "lastLoggedInPassword")
    }
    
    private func updatePassword() {
        guard !tempPassword.isEmpty else {
            errorMessage = "Old password cannot be empty."
            return
        }
        guard !newPassword.isEmpty else {
            errorMessage = "New password cannot be empty."
            return
        }
        guard !confirmPassword.isEmpty else {
            errorMessage = "Confirm password cannot be empty."
            return
        }
        guard tempPassword == user.password else {
            errorMessage = "Old password is incorrect."
            return
        }
        guard newPassword == confirmPassword else {
            errorMessage = "New passwords do not match."
            return
        }
        
        user.password = newPassword
        tempPassword = ""
        newPassword = ""
        confirmPassword = ""
        errorMessage = nil
        isEditingPassword = false
    }
}

struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?

    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker

        init(_ parent: ImagePicker) {
            self.parent = parent
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
            if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }

        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            picker.dismiss(animated: true)
        }
    }

    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.delegate = context.coordinator
        picker.allowsEditing = false // 若要支援裁剪圖片，可改為 true
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
}
