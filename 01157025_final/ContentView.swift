//
//  ContentView.swift
//  01157025_final
//
//  Created by user10 on 2024/11/28.
//

import SwiftUI
import SwiftData
import Charts
import TipKit

struct ContentView: View {
    @State private var isLoggedIn = false
    @State private var currentUser: User? = nil
    @StateObject private var weatherViewModel = WeatherViewModel()
    
    var body: some View {
        Group {
            if isLoggedIn {
                MainTabView(currentUser: $currentUser, isLoggedIn: $isLoggedIn)
                    .environmentObject(weatherViewModel)
            } else {
                LoginView(isLoggedIn: $isLoggedIn, currentUser: $currentUser)
            }
        }
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [User.self, ActivityRecord.self, Goal.self]/*, inMemory: true*/)
}
