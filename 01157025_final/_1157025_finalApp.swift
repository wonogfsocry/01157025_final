//
//  _1157025_finalApp.swift
//  01157025_final
//
//  Created by user10 on 2024/11/28.
//

import SwiftUI
import SwiftData
import TipKit

@main
struct HealthTrackerApp: App {
    init() {
        // 初始化 TipKit 設定
        try? Tips.resetDatastore()
        try? Tips.configure([
            .displayFrequency(.daily)
        ])
        setupTabBarAppearance()
    }

    var body: some Scene {
        WindowGroup {
            ContentView() // 使用 ContentView 作為主入口
                .modelContainer(for: [User.self, ActivityRecord.self, Goal.self])
        }
    }
    private func setupTabBarAppearance() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        
        // 設定背景顏色為漸層
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemBlue.withAlphaComponent(0.7).cgColor,
                                UIColor.systemPurple.withAlphaComponent(0.7).cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0)
        gradientLayer.endPoint = CGPoint(x: 1, y: 1)
        gradientLayer.frame = CGRect(x: 0, y: 0, width: UIScreen.main.bounds.width, height: 49) // Tab Bar 預設高度
        
        let gradientImage = UIImage.fromLayer(layer: gradientLayer)
        tabBarAppearance.backgroundImage = gradientImage
        
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.white
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white]
        
        // 設定全局 TabBar 樣式
        UITabBar.appearance().standardAppearance = tabBarAppearance
        if #available(iOS 15.0, *) {
            UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
        }
    }
}

// UIImage 擴展，用來從 CAGradientLayer 生成圖片
extension UIImage {
    static func fromLayer(layer: CALayer) -> UIImage {
        let renderer = UIGraphicsImageRenderer(size: layer.frame.size)
        return renderer.image { ctx in
            layer.render(in: ctx.cgContext)
        }
    }
}
