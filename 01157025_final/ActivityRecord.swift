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
    @Attribute var value: Double // 喝水: ml, 運動: 卡路里, 睡眠: 小時
    @Attribute var date: Date // 主要日期（喝水用）
    @Attribute var startTime: Date? // 開始時間（睡眠或運動）
    @Attribute var endTime: Date?   // 結束時間（睡眠或運動）
    @Attribute var notes: String?
    @Relationship var user: User? // 關聯到用戶
        
    init(type: ActivityType, title: String, value: Double, date: Date, startTime: Date? = nil, endTime: Date? = nil, notes: String? = nil) {
        self.id = UUID()
        self.type = type
        self.title = title
        self.value = value
        self.date = date
        self.startTime = startTime
        self.endTime = endTime
        self.notes = notes
    }
}
