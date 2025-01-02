//
//  Analysis.swift
//  01157025_final
//
//  Created by user10 on 2024/12/3.
//

import SwiftUI
import SwiftData
import Charts

struct WeeklySummary: Identifiable {
    let id = UUID()
    let date: Date
    let exercise: Double // 运动量
    let hydration: Double // 喝水量
    let sleep: Double // 睡觉量
}

func generateWeeklyData(from records: [ActivityRecord]) -> [WeeklySummary] {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    var weeklyData: [WeeklySummary] = []
    
    for offset in 0..<7 {
        let day = calendar.date(byAdding: .day, value: -offset, to: today)!
        let filteredRecords = records.filter { calendar.isDate($0.date, inSameDayAs: day) }
        
        let exercise = filteredRecords
            .filter { $0.type == .exercise }
            .map { $0.value }
            .reduce(0, +)
        let hydration = filteredRecords
            .filter { $0.type == .hydration }
            .map { $0.value }
            .reduce(0, +)
        let sleep = filteredRecords
            .filter { $0.type == .sleep }
            .map { $0.value }
            .reduce(0, +)
        
        weeklyData.append(WeeklySummary(date: day, exercise: exercise, hydration: hydration, sleep: sleep))
    }
    return weeklyData.reversed() // 按日期正序排列
}

struct WeeklyChartView: View {
    let weeklyData: [WeeklySummary]
    
    var body: some View {
        Chart {
            ForEach(weeklyData) { summary in
                LineMark(
                    x: .value("Date", summary.date, unit: .day),
                    y: .value("Exercise", summary.exercise)
                )
                .foregroundStyle(.blue)
                .symbol(.circle)
                
                LineMark(
                    x: .value("Date", summary.date, unit: .day),
                    y: .value("Hydration", summary.hydration)
                )
                .foregroundStyle(.teal)
                .symbol(.square)
                
                LineMark(
                    x: .value("Date", summary.date, unit: .day),
                    y: .value("Sleep", summary.sleep)
                )
                .foregroundStyle(.purple)
                .symbol(.diamond)
            }
        }
        .chartXAxis {
            AxisMarks(values: .stride(by: .day)) {
                AxisValueLabel(format: .dateTime.day().month().weekday())
            }
        }
        .chartYAxis {
            AxisMarks { value in
                AxisValueLabel(format: .number)
            }
        }
        .frame(height: 300)
        .padding()
        .navigationTitle("7-Day Activity Trends")
    }
}

struct WeeklyAnalysisView: View {
    let weeklyData: [WeeklySummary]
    
    var totalExercise: Double {
        weeklyData.map { $0.exercise }.reduce(0, +)
    }
    var totalHydration: Double {
        weeklyData.map { $0.hydration }.reduce(0, +)
    }
    var totalSleep: Double {
        weeklyData.map { $0.sleep }.reduce(0, +)
    }
    
    var body: some View {
        List {
            Section(header: Text("Exercise Analysis")) {
                Text("Total: \(totalExercise, specifier: "%.1f") kcal")
                Text("Average: \(totalExercise / 7, specifier: "%.1f") kcal/day")
            }
            Section(header: Text("Hydration Analysis")) {
                Text("Total: \(totalHydration, specifier: "%.1f") ml")
                Text("Average: \(totalHydration / 7, specifier: "%.1f") ml/day")
            }
            Section(header: Text("Sleep Analysis")) {
                Text("Total: \(totalSleep, specifier: "%.1f") hrs")
                Text("Average: \(totalSleep / 7, specifier: "%.1f") hrs/day")
            }
        }
        .navigationTitle("Weekly Analysis")
    }
}

struct AnalysisView: View {
    @Query var records: [ActivityRecord]
    var weeklyData: [WeeklySummary] {
        generateWeeklyData(from: records)
    }
    
    var body: some View {
        VStack {
            WeeklyChartView(weeklyData: weeklyData)
            WeeklyAnalysisView(weeklyData: weeklyData)
        }
        .navigationTitle("Weekly Activity")
    }
}
