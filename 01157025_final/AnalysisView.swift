//
//  Analysis.swift
//  01157025_final
//
//  Created by user10 on 2024/12/3.
//

import SwiftUI
import SwiftData
import Charts
import TipKit



struct WeeklySummary: Identifiable {
    let id = UUID()
    let date: Date
    let exercise: Double // 运动量
    let hydration: Double // 喝水量
    let sleep: Double // 睡觉量
}

func generateWeeklyData(from records: [ActivityRecord], for user: User, startingFrom startDate: Date) -> [WeeklySummary] {
    let calendar = Calendar.current
    let today = calendar.startOfDay(for: Date())
    var weeklyData: [WeeklySummary] = []
    var currentUser: User
    let userRecords = records.filter { $0.user == user }
    
    for offset in 0..<7 {
        
        let day = calendar.date(byAdding: .day, value: offset, to: startDate)!
        let filteredRecords = userRecords.filter { calendar.isDate($0.date, inSameDayAs: day) }
        
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
    @State private var selectedChart: ActivityType = .exercise // 默認顯示運動量圖表
    
    let chartPickerTip = ChartPickerTip() // 定義 Chart Picker Tip
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景漸變
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // 提示區塊
                    TipView(chartPickerTip, arrowEdge: .bottom) { _ in
                        Color.clear.frame(height: 0)
                    }
                    .padding(.top, 10)
                    
                    // 圖表類型選擇
                    SectionContainer(title: "Select Chart Type") {
                        Picker("Chart Type", selection: $selectedChart) {
                            Text("Exercise").tag(ActivityType.exercise)
                            Text("Hydration").tag(ActivityType.hydration)
                            Text("Sleep").tag(ActivityType.sleep)
                        }
                        .pickerStyle(SegmentedPickerStyle())
                        .padding(.horizontal, 10)
                    }
                    
                    // 圖表展示
                    SectionContainer(title: chartTitle(for: selectedChart)) {
                        Chart {
                            ForEach(weeklyData) { summary in
                                switch selectedChart {
                                case .exercise:
                                    LineMark(
                                        x: .value("Day", summary.date, unit: .day),
                                        y: .value("Exercise", summary.exercise)
                                    )
                                    .foregroundStyle(.blue)
                                    .symbol(.circle)
                                case .hydration:
                                    LineMark(
                                        x: .value("Day", summary.date, unit: .day),
                                        y: .value("Hydration", summary.hydration)
                                    )
                                    .foregroundStyle(.teal)
                                    .symbol(.square)
                                case .sleep:
                                    LineMark(
                                        x: .value("Day", summary.date, unit: .day),
                                        y: .value("Sleep", summary.sleep)
                                    )
                                    .foregroundStyle(.purple)
                                    .symbol(.diamond)
                                }
                            }
                        }
                        .chartXAxis {
                            AxisMarks(values: weeklyData.map { $0.date }) { value in
                                if let date = value.as(Date.self) {
                                    AxisValueLabel(date.formatted(.dateTime.weekday(.abbreviated)))
                                }
                            }
                        }
                        .chartYAxis {
                            AxisMarks { value in
                                AxisValueLabel(format: FloatingPointFormatStyle<Double>())
                            }
                        }
                        .frame(height: 300)
                        .padding()
                    }
                }
                .padding()
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Analysis Activity")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    private func chartTitle(for type: ActivityType) -> String {
        switch type {
        case .exercise: return "Exercise Data"
        case .hydration: return "Hydration Data"
        case .sleep: return "Sleep Data"
        }
    }
}

struct WeeklyAnalysisView: View {
    let weeklyData: [WeeklySummary]
    let weeklySummaryTip = WeeklySummaryTip() // 定義 Weekly Summary Tip
    
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
        NavigationStack {
            ZStack {
                // 背景漸變
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.8)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 提示區塊
                        TipView(weeklySummaryTip, arrowEdge: .bottom) { _ in
                            Color.clear.frame(height: 0)
                        }
                        .padding(.top, 10)
                        
                        // 運動分析區塊
                        SectionContainer(title: "Exercise Analysis") {
                            HStack(spacing: 8) {
                                Text("Total: \(totalExercise, specifier: "%.1f") kcal")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("Average: \(totalExercise / 7, specifier: "%.1f") kcal/day")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        // 飲水分析區塊
                        SectionContainer(title: "Hydration Analysis") {
                            HStack(spacing: 8) {
                                Text("Total: \(totalHydration, specifier: "%.1f") ml")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("Average: \(totalHydration / 7, specifier: "%.1f") ml/day")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        // 睡眠分析區塊
                        SectionContainer(title: "Sleep Analysis") {
                            HStack(spacing: 8) {
                                Text("Total: \(totalSleep, specifier: "%.1f") hrs")
                                    .font(.headline)
                                    .foregroundColor(.white)
                                Spacer()
                                Text("Average: \(totalSleep / 7, specifier: "%.1f") hrs/day")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                    }
                    .padding()
                }
            }
            .navigationTitle("Weekly Analysis")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct AnalysisView: View {
    @Query var records: [ActivityRecord]
    @State private var selectedStartDate = Calendar.current.startOfDay(for: Date())
    @State private var weeklyData: [WeeklySummary] = []
    var currentUser: User
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景漸變
                LinearGradient(
                    gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.6)]),
                    startPoint: .top,
                    endPoint: .bottom
                )
                .ignoresSafeArea()
                ScrollView{
                    VStack {
                        HStack{
                            Text("Select Start Date:")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding()
                            DatePicker("", selection: $selectedStartDate, displayedComponents: .date)
                                .padding()
                                .onChange(of: selectedStartDate) { newStartDate in
                                    // 更新 weeklyData，每次选择的开始日期变化时
                                    weeklyData = generateWeeklyData(from: records, for: currentUser, startingFrom: newStartDate)
                                }
                        }
                        // 显示图表
                        WeeklyChartView(weeklyData: weeklyData)
                        
                        WeeklyAnalysisView(weeklyData: weeklyData)
                        
                    }
                    .navigationTitle("Analysis")
                    .onAppear {
                        weeklyData = generateWeeklyData(from: records, for: currentUser, startingFrom: selectedStartDate)
                    }
                }
            }
        }
    }
}
