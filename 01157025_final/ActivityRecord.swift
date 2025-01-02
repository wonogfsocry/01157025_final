//
//  ExerciseRecord.swift
//  01157025_final
//
//  Created by user10 on 2024/11/28.
//

import SwiftData
import SwiftUI

enum ActivityType: String, Codable, CaseIterable {
    case exercise = "Exercise"
    case hydration = "Hydration"
    case sleep = "Sleep"
}

@Model
class ActivityRecord {
    @Attribute var id: UUID
        @Attribute var type: ActivityType
        @Attribute var title: String
        @Attribute var value: Double // 運動:卡路里，喝水:ml，睡眠:小時
        @Attribute var date: Date
        @Attribute var notes: String?
        
        init(type: ActivityType, title: String, value: Double, date: Date, notes: String? = nil) {
            self.id = UUID()
            self.type = type
            self.title = title
            self.value = value
            self.date = date
            self.notes = notes
        }
}
