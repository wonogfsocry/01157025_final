//
//  GoalView.swift
//  01157025_final
//
//  Created by user10 on 2024/11/28.
//
import SwiftUI
import SwiftData
import TipKit
import Charts
import Lottie

struct LottieView: UIViewRepresentable {
    var name: String
    var loopMode: LottieLoopMode = .playOnce // 設定成 Lottie 提供的播放模式
    
    func makeUIView(context: Context) -> LottieAnimationView {
        let view = LottieAnimationView(name: name) // 創建動畫實例
        view.loopMode = loopMode
        view.play() // 播放動畫
        return view
    }
    
    func updateUIView(_ uiView: LottieAnimationView, context: Context) {}
}

@Model
class Goal {
    @Attribute var id: UUID
    @Attribute var type: ActivityType
    @Attribute var targetValue: Double // 喝水: ml, 運動: 卡路里, 睡眠: 小時
    @Attribute var startDate: Date
    @Attribute var endDate: Date
    @Relationship var user: User? // 關聯到用戶
    
    init(type: ActivityType, targetValue: Double, startDate: Date, endDate: Date) {
        self.id = UUID()
        self.type = type
        self.targetValue = targetValue
        self.startDate = startDate
        self.endDate = endDate
    }
}

struct SetGoalView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: ActivityType = .exercise
    @State private var targetValue: String = ""
    @State private var startTime = Calendar.current.startOfDay(for: Date())
    @State private var endTime = Calendar.current.date(byAdding: .day, value: 1, to: Date()) ?? Date()
    
    var currentUser: User
    
    var valuePlaceholder: String {
        switch selectedType {
        case .exercise: return "Calorie target"
        case .hydration: return "Water target"
        case .sleep: return "Sleep target"
        }
    }
    
    var stepValue: Double {
        switch selectedType {
        case .hydration: return 100
        case .sleep: return 0.1
        case .exercise: return 10
        }
    }
    
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
                    
                    ScrollView {
                        VStack(spacing: 20) {
                            // 目標類型選擇
                            SectionContainer(title: "Goal Type") {
                                Picker("Type", selection: $selectedType) {
                                    ForEach(ActivityType.allCases, id: \.self) { type in
                                        Text(type.rawValue.capitalized).tag(type)
                                    }
                                }
                                .pickerStyle(SegmentedPickerStyle())
                                .padding(.horizontal)
                            }
                            
                            // 設定日期和時間
                            SectionContainer(title: "Set Date and Time") {
                                VStack(spacing: 10) {
                                    HStack{
                                        Spacer()
                                        DatePicker("Start Date", selection: $startTime, displayedComponents: .date)
                                            .datePickerStyle(CompactDatePickerStyle())
                                            .labelsHidden()
                                            .tint(.white)
                                        Text("~")
                                            .font(.headline)
                                            .foregroundColor(.black)
                                        DatePicker("End Date", selection: $endTime, displayedComponents: .date)
                                            .datePickerStyle(CompactDatePickerStyle())
                                            .labelsHidden()
                                            .tint(.white)
                                        Spacer()
                                    }
                                }
                            }
                            
                            // 設定詳細目標值
                            SectionContainer(title: "Details") {
                                HStack {
                                    Text(valuePlaceholder)
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    TextField("Enter value", text: $targetValue)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(maxWidth: 100)
                                    Stepper("", value: Binding(
                                        get: { Double(targetValue) ?? 0 },
                                        set: { targetValue = String($0) }
                                    ), step: stepValue)
                                    .labelsHidden()
                                }
                            }
                            
                            // 添加目標按鈕
                            Button(action: setGoal) {
                                Text("Set Goal")
                                    .font(.headline)
                                    .foregroundColor(Color.white) // 动态设置文字颜色
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        Group {
                                            if isButtonDisabled() {
                                                Color.gray.opacity(0.5) // 禁用时为灰色背景
                                            } else {
                                                LinearGradient(
                                                    gradient: Gradient(colors: [Color.blue, Color.purple]),
                                                    startPoint: .topLeading,
                                                    endPoint: .bottomTrailing
                                                )
                                            }
                                        }
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(isButtonDisabled() ? 0 : 0.2), radius: 5, x: 0, y: 3) // 禁用时去掉阴影
                            }
                            .disabled(isButtonDisabled())
                        }
                        .padding()
                    }
                }
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("Set Goal")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                            .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                    }
                }
        }
    }
    
    private func isButtonDisabled() -> Bool {
        return Double(targetValue) ?? 0 <= 0 || startTime > endTime
    }
    
    private func setGoal() {
        guard let target = Double(targetValue), target > 0 else { return }
        let normalizedEndTime = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: endTime) ?? endTime
        let newGoal = Goal(type: selectedType, targetValue: target, startDate: startTime, endDate: normalizedEndTime)
        currentUser.goals.append(newGoal)
        modelContext.insert(newGoal)
        dismiss()
    }
}

struct GoalProgressView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedDate = Date() // 日期篩選
    @State private var showSuccessAnimation = false
    let progressTip = ProgressMeaningTip()
    let filterTip = GoalProgressTip()
    let addGoalTip = AddGoalTip()
    var currentUser: User
    
    // 篩選當前用戶的目標
    var filteredGoals: [Goal] {
        currentUser.goals.filter { goal in
            selectedDate >= goal.startDate && selectedDate <= goal.endDate
        }
    }
    
    // 當前用戶的活動記錄
    var userRecords: [ActivityRecord] {
        currentUser.activityRecords
    }
    
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
                    // 日期選擇器
                    VStack {
                        Text("Filter Date")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding(.bottom, 5)
                        
                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .background(Color.white.opacity(0.2))
                            .cornerRadius(12)
                            .padding(.horizontal, 20)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                    
                    if filteredGoals.isEmpty {
                        // 沒有目標時的提示
                        VStack(spacing: 10) {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundColor(.yellow)
                                .font(.largeTitle)
                            Text("No goals for the selected date")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding(.top, 40)
                    } else {
                        // 目標列表
                        List {
                            ForEach(filteredGoals) { goal in
                                NavigationLink(destination: GoalDetailView(goal: goal)) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Text(goal.type.rawValue.capitalized)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Spacer()
                                            if progress(for: goal, on: selectedDate, from: userRecords) >= 1.0 {
                                                LottieView(name: "check", loopMode: .playOnce)
                                                    .frame(width: 40, height: 40)
                                                    .padding()
                                            }
                                        }
                                        
                                        // 進度條及數據
                                        let progressValue = progress(for: goal, on: selectedDate, from: userRecords)
                                        let completedValue = progressValue * goal.targetValue
                                        let remainingValue = max(goal.targetValue - completedValue, 0)
                                        
                                        ProgressView(value: progressValue)
                                            .progressViewStyle(LinearProgressViewStyle(tint: progressValue >= 1.0 ? .green : .blue))
                                            .frame(height: 10)
                                        
                                        HStack {
                                            VStack(alignment: .leading) {
                                                Text("Target: \(goal.targetValue, specifier: "%.1f")")
                                                    .foregroundColor(.white.opacity(0.8))
                                                Text("Completed: \(completedValue, specifier: "%.1f")")
                                                    .foregroundColor(.white.opacity(0.8))
                                            }
                                            Spacer()
                                            VStack(alignment: .trailing) {
                                                Text("Remaining: \(remainingValue, specifier: "%.1f")")
                                                    .foregroundColor(.yellow)
                                                Text("\(goal.startDate, style: .date) - \(goal.endDate, style: .date)")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.6))
                                            }
                                        }
                                        .font(.footnote)
                                    }
                                    .padding()
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.5)]),
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        )
                                    )
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                                }
                                .listRowBackground(Color.clear) // 清除系統背景
                            }
                        }
                        .listStyle(.insetGrouped)
                        .scrollContentBackground(.hidden) // 隱藏列表背景
                    }
                }
                .padding(.top, 20)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Goal Progress")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: SetGoalView(currentUser: currentUser)) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.purple.opacity(0.8))
                            .cornerRadius(8)
                    }
                }
            }
        }
    }
    
    /// 計算進度，按日期篩選活動記錄
    func progress(for goal: Goal, on date: Date, from records: [ActivityRecord]) -> Double {
        let completed = records
            .filter {
                $0.type == goal.type &&
                $0.date >= goal.startDate &&
                $0.date <= goal.endDate
            }
            .map { $0.value }
            .reduce(0, +)
        return min(completed / goal.targetValue, 1.0) // 確保進度不超過 100%
    }
    func stopAnimation(){
        showSuccessAnimation=true
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            showSuccessAnimation = false
        }
    }
}

struct GoalDetailView: View {
    var goal: Goal
    @Query var records: [ActivityRecord] // 用于显示目标相关的活动记录
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // 背景漸變
            LinearGradient(
                gradient: Gradient(colors: [Color.purple.opacity(0.8), Color.blue.opacity(0.6)]),
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
            
            ScrollView {
                VStack(spacing: 20) {
                    // 目標詳情區塊
                    SectionContainer(title: "Goal Details") {
                        VStack(alignment: .leading, spacing: 10) {
                            Text("Type: \(goal.type.rawValue.capitalized)")
                                .font(.headline)
                                .foregroundColor(.white)
                            Text("Target Value: \(goal.targetValue, specifier: "%.1f")")
                                .font(.headline)
                                .foregroundColor(.white.opacity(0.8))
                            HStack{
                                Text("\(goal.startDate, style: .date) ")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                Text("~")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                Text(" \(goal.endDate, style: .date)")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    
                    // 進度區塊
                    SectionContainer(title: "Progress") {
                        let progressValue = progress(for: goal, from: records)
                        let completedValue = progressValue * goal.targetValue
                        let remainingValue = max(goal.targetValue - completedValue, 0)
                        
                        VStack(alignment: .leading, spacing: 10) {
                            ProgressView(value: progressValue)
                                .progressViewStyle(LinearProgressViewStyle(
                                    tint: progressValue >= 1.0 ? .green : .blue
                                ))
                                .frame(height: 10)
                            
                            HStack {
                                Text("Completed: \(completedValue, specifier: "%.1f")")
                                    .foregroundColor(.white.opacity(0.8))
                                Spacer()
                                Text("Remaining: \(remainingValue, specifier: "%.1f")")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        .padding(.vertical, 10)
                    }
                    
                    // 相關活動區塊
                    SectionContainer(title: "Related Activities") {
                        let relatedRecords = records.filter {
                            $0.type == goal.type && $0.date >= goal.startDate && $0.date <= goal.endDate
                        }
                        if relatedRecords.isEmpty {
                            Text("No related activities found.")
                                .foregroundColor(.white.opacity(0.6))
                        } else {
                            ScrollView(.horizontal){
                                HStack(spacing: 10) {
                                    ForEach(relatedRecords) { record in
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text(record.title)
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            Text("\(record.value, specifier: "%.1f") \(unit(for: record.type))")
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.8))
                                            if let startTime = record.startTime, let endTime = record.endTime {
                                                Text("\(startTime, style: .time) - \(endTime, style: .time)")
                                                    .font(.caption)
                                                    .foregroundColor(.white.opacity(0.6))
                                            }
                                        }
                                        .padding()
                                        .background(
                                            LinearGradient(
                                                gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.5)]),
                                                startPoint: .topLeading,
                                                endPoint: .bottomTrailing
                                            )
                                        )
                                        .cornerRadius(12)
                                        .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                                    }
                                }
                            }
                        }
                    }
                    
                    // 刪除按鈕
                    Button(role: .destructive) {
                        deleteRecord()
                    } label: {
                        Text("Delete Goal")
                            .font(.headline)
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(
                                LinearGradient(
                                    gradient: Gradient(colors: [Color.red.opacity(0.8), Color.red.opacity(0.6)]),
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                )
                            )
                            .cornerRadius(12)
                            .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                    }
                    .padding(.top, 20)
                }
                .padding()
            }
        }
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Goal Detail")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
            }
        }
    }
    
    private func deleteRecord() {
        modelContext.delete(goal) // 删除记录
        dismiss() // 返回上一页面
    }
    
    private func unit(for type: ActivityType) -> String {
        switch type {
        case .hydration:
            return "ml"
        case .exercise:
            return "kcal"
        case .sleep:
            return "hrs"
        }
    }
    
    private func progress(for goal: Goal, from records: [ActivityRecord]) -> Double {
        let completed = records
            .filter { $0.type == goal.type && $0.date >= goal.startDate && $0.date <= goal.endDate }
            .map { $0.value }
            .reduce(0, +)
        return min(completed / goal.targetValue, 1.0) // 确保进度不超过 100%
    }
}
