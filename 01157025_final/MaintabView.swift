//
//  MaintabView.swift
//  01157025_final
//
//  Created by user10 on 2024/12/10.
//
import SwiftUI
import SwiftData

struct MainTabView: View {
    @Binding var currentUser: User?
    @Binding var isLoggedIn: Bool
    @EnvironmentObject var weatherViewModel: WeatherViewModel

    @State private var circlePosition = CGPoint(x: 50, y: 100) // 可拖動圓圈的位置
    @State private var isWeatherDetailPresented = false // 是否顯示天氣詳細資訊

    var body: some View {
        ZStack {
            // TabView 主內容
            TabView {
                if let user = currentUser {
                    ActivityListView(currentUser: user)
                        .tabItem {
                            Label("Activities", systemImage: "list.bullet")
                        }
                    
                    GoalProgressView(currentUser: user)
                        .tabItem {
                            Label("Goals", systemImage: "target")
                        }
                    
                    AnalysisView(currentUser: user)
                        .tabItem {
                            Label("Analysis", systemImage: "chart.xyaxis.line")
                        }
                    
                    UserSettingsView(user: user, isLoggedIn: $isLoggedIn)
                        .tabItem {
                            Label("Setting", systemImage: "gearshape")
                        }
                }
            }
            
            // 可移動的小圓圈
            Circle()
                .fill(Color.white.opacity(0.5))
                .frame(width: 60, height: 60)
                .overlay {
                    if let icon = weatherViewModel.weatherIcon {
                        AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")) { image in
                            image.resizable()
                                .scaledToFit()
                                .frame(width: 40, height: 40)
                        } placeholder: {
                            ProgressView()
                        }
                    }
                }
                .shadow(radius: 5)
                .position(circlePosition)
                .gesture(
                    DragGesture()
                        .onChanged { value in
                            circlePosition = value.location
                        }
                )
                .onTapGesture {
                    isWeatherDetailPresented = true
                }
                .sheet(isPresented: $isWeatherDetailPresented) {
                    WeatherDetailView()
                        .environmentObject(weatherViewModel)
                        .presentationDetents([.fraction(0.68)]) // 控制尺寸
                        .presentationDragIndicator(.visible) // 顯示拖動指示器
                }
        }
        .onAppear {
            weatherViewModel.fetchWeather()
        }
    }
}

struct WeatherDetailView: View {
    @EnvironmentObject var weatherViewModel: WeatherViewModel
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景漸變
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.7), Color.blue.opacity(0.7)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 30) {
                        // 卡片內容
                        VStack(spacing: 20) {
                            Text("Weather Details")
                                .font(.largeTitle)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                                .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                            
                            if let temp = weatherViewModel.temperature,
                               let feelsLike = weatherViewModel.feelsLikeTemperature,
                               let humidity = weatherViewModel.humidity,
                               let windSpeed = weatherViewModel.windSpeed,
                               let pressure = weatherViewModel.pressure,
                               let cloudiness = weatherViewModel.cloudiness,
                               let icon = weatherViewModel.weatherIcon {
                                
                                VStack(spacing: 15) {
                                    // 天氣圖標和城市名稱
                                    AsyncImage(url: URL(string: "https://openweathermap.org/img/wn/\(icon)@2x.png")) { image in
                                        image.resizable()
                                            .scaledToFit()
                                            .frame(width: 100, height: 100)
                                    } placeholder: {
                                        ProgressView()
                                    }
                                    
                                    Text("\(weatherViewModel.city)")
                                        .font(.title)
                                        .fontWeight(.bold)
                                        .foregroundColor(.white)
                                    
                                    Text("\(String(format: "%.1f", temp))°C")
                                        .font(.largeTitle)
                                        .fontWeight(.semibold)
                                        .foregroundColor(.blue)
                                    
                                    // 額外天氣資訊
                                    VStack(alignment: .leading, spacing: 10) {
                                        HStack {
                                            Text("Feels Like:")
                                            Spacer()
                                            Text("\(String(format: "%.1f", feelsLike))°C")
                                        }
                                        HStack {
                                            Text("Humidity:")
                                            Spacer()
                                            Text("\(humidity)%")
                                        }
                                        HStack {
                                            Text("Wind Speed:")
                                            Spacer()
                                            Text("\(String(format: "%.1f", windSpeed)) m/s")
                                        }
                                        HStack {
                                            Text("Pressure:")
                                            Spacer()
                                            Text("\(pressure) hPa")
                                        }
                                        HStack {
                                            Text("Cloudiness:")
                                            Spacer()
                                            Text("\(cloudiness)%")
                                        }
                                    }
                                    .font(.body)
                                    .foregroundColor(.white)
                                    .padding()
                                    .background(Color.white.opacity(0.2))
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                                }
                            } else {
                                Text("Loading weather data...")
                                    .foregroundColor(.white)
                                    .font(.body)
                            }
                        }
                        .padding()
                        .background(Color.white.opacity(0.2))
                        .cornerRadius(12)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                    .padding()
                }
            }
        }
    }
}
struct LogoutView: View {
    @Binding var isLoggedIn: Bool

    var body: some View {
        VStack {
            Text("Are you sure you want to log out?")
                .font(.headline)
                .padding()

            Button("Log Out") {
                logout()
            }
            .padding()
            .foregroundColor(.red)
        }
    }

    private func logout() {
        clearLastLogin() // 清除上次登入的資訊
        isLoggedIn = false
    }

    private func clearLastLogin() {
        UserDefaults.standard.removeObject(forKey: "lastLoggedInUsername")
        UserDefaults.standard.removeObject(forKey: "lastLoggedInPassword")
    }
}
