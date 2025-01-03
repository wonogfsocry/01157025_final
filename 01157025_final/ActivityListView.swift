//
//  Untitled.swift
//  01157025_final
//
//  Created by user10 on 2024/11/28.
//
import SwiftUI
import SwiftData
import Charts
import TipKit

extension Binding where Value == Date? {
    func replacingNilWith(_ defaultValue: Date) -> Binding<Date> {
        Binding<Date>(
            get: { self.wrappedValue ?? defaultValue },
            set: { self.wrappedValue = $0 }
        )
    }
}

struct ActivityListView: View {
    @Query var records: [ActivityRecord]
    @State private var searchText: String = ""
    @State private var startDate: Date = Calendar.current.startOfDay(for: Date()) // 預設為當天的 12:00 AM
    @State private var endDate: Date = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date()) ?? Date() // 預設為當天的 11:59 PM
    let dateRangeTip = DateRangeTip()
    var currentUser: User
    
    var filteredRecords: [ActivityRecord] {
        records.filter { record in
            guard record.user == currentUser else { return false }
            let matchesTitle = searchText.isEmpty || record.title.localizedCaseInsensitiveContains(searchText)
            let matchesDateRange = record.date >= startDate && record.date <= endDate
            return matchesTitle && matchesDateRange
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
                
                VStack(spacing: 15) {
                    // 日期選擇器
                    VStack(spacing: 15) {
                        //TipView(dateRangeTip, arrowEdge: .bottom)
                        HStack(spacing: 15) {
                            VStack {
                                Text("From")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                DatePicker(
                                    "",
                                    selection: Binding<Date>(
                                        get: { startDate },
                                        set: { newValue in
                                            let newStartDate = Calendar.current.startOfDay(for: newValue) // 设置为选定日期的 12:00 AM
                                            startDate = newStartDate
                                            
                                            // 如果 To 的时间早于 From，则将 To 调整为当天的 11:59 PM
                                            if endDate < newStartDate {
                                                endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: newStartDate) ?? newStartDate
                                            }
                                        }
                                    ),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden() // 隐藏标签
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                            }
                            VStack {
                                Text("To")
                                    .font(.caption)
                                    .foregroundColor(.white.opacity(0.8))
                                DatePicker(
                                    "",
                                    selection: Binding<Date>(
                                        get: { endDate },
                                        set: { newValue in
                                            // 设置 To 为当天的 11:59 PM
                                            let newEndDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: newValue) ?? newValue
                                            endDate = newEndDate
                                            
                                            // 如果 To 比 From 早，则调整 To 为 From 当天的 11:59 PM
                                            if newEndDate < startDate {
                                                endDate = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: startDate) ?? startDate
                                            }
                                        }
                                    ),
                                    displayedComponents: .date
                                )
                                .datePickerStyle(.compact)
                                .labelsHidden() // 隐藏标签
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                            }
                        }
                    }
                    .padding()
                    .background(Color.purple.opacity(0.3))
                    .cornerRadius(12)
                    .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                    
                    // 列表區域
                    if filteredRecords.isEmpty {
                        ContentUnavailableView("No Records", systemImage: "list.bullet")
                            .foregroundColor(.white.opacity(0.7))
                    } else {
                        List {
                            ForEach(ActivityType.allCases, id: \.self) { type in
                                Section(header: Text(type.rawValue)
                                    .font(.headline)
                                    .foregroundColor(.white.opacity(0.8))
                                    .padding(.vertical, 5)
                                    .background(Color.clear) // 設置背景為透明
                                ) {
                                    ForEach(filteredRecords.filter { $0.type == type }) { record in
                                        NavigationLink(destination: ActivityDetailView(record: record)) {
                                            VStack(alignment: .leading, spacing: 8) {
                                                HStack{
                                                    Text(record.title)
                                                        .font(.headline)
                                                        .foregroundColor(.white)
                                                    Text(typeDetail(for: record))
                                                        .font(.subheadline)
                                                        .foregroundColor(.white.opacity(0.8))
                                                }
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
                                        .listRowBackground(Color.clear)
                                    }
                                }
                            }
                        }
                        .background(Color.clear) // 清除默认背景
                        .scrollContentBackground(.hidden)
                        .listStyle(InsetGroupedListStyle()) // 替换为不同的样式
                        .padding(.top, -10) // 去掉顶部间隙
                        .padding(.bottom, -10) // 去掉底部间隙
                    }
                }
                .padding(.horizontal, 16)
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Activity Tracker")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                }
                ToolbarItem(placement: .primaryAction) {
                    NavigationLink(destination: AddActivityView(currentUser: currentUser)) {
                        Image(systemName: "plus")
                            .foregroundColor(.white)
                            .padding(8)
                            .background(Color.purple.opacity(0.8))
                            .cornerRadius(8)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "Search activities")
        }
    }
    
    private func typeDetail(for record: ActivityRecord) -> String {
        switch record.type {
        case .exercise:
            return "Calories: \(String(format: "%.1f", record.value)) kcal"
        case .hydration:
            return "Water: \(String(format: "%.1f", record.value)) ml"
        case .sleep:
            return "Sleep: \(String(format: "%.1f", record.value)) hrs"
        }
    }
}

struct AddActivityView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    
    @State private var selectedType: ActivityType = .exercise
    @State private var title = "No title"
    @State private var value: String = ""
    @State private var date = Date() // 運動和喝水使用此日期
    @State private var startTime: Date = Date()
    @State private var endTime: Date = Date()
    @State private var notes = ""
    
    let selectActivityTypeTip = SelectActivityTypeTip()
    let inputDataTip = InputDataTip()
    let sleepTimeTip = SleepTimeTip()
    let addRecordTip = AddRecordTip()
    
    var currentUser: User
    
    var calculatedSleepHours: Double {
        guard selectedType == .sleep, startTime < endTime else { return 0 }
        return endTime.timeIntervalSince(startTime) / 3600.0
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
                        // 活動類型選擇
                        SectionContainer(title: "Activity Type") {
                            Picker("Type", selection: $selectedType) {
                                ForEach(ActivityType.allCases, id: \.self) { type in
                                    Text(type.rawValue.capitalized).tag(type)
                                }
                            }
                            .pickerStyle(SegmentedPickerStyle())
                        }
                        
                        // Hydration 記錄
                        if selectedType == .hydration {
                            SectionContainer(title: "Date") {
                                HStack{
                                    DatePicker("Date", selection: $date, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .tint(.white)
                                    Spacer()
                                    DatePicker("Time", selection: $date, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .tint(.white)
                                }
                            }
                            SectionContainer(title: "Hydration") {
                                
                                TipView(inputDataTip, arrowEdge: .bottom)
                                HStack {
                                    Text("Water Drink:")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                    TextField("Enter value", text: $value)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(maxWidth: 100)
                                    Stepper("", value: Binding(
                                        get: { Double(value) ?? 0 },
                                        set: { value = String($0) }
                                    ), step: 100)
                                    .labelsHidden()
                                }
                                .padding(.vertical, 5)
                            }
                        }
                        
                        // Sleep 記錄
                        else if selectedType == .sleep {
                            SectionContainer(title: "Sleep") {
                                TipView(sleepTimeTip, arrowEdge: .bottom)
                                DatePicker("Start Time", selection: $startTime, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .tint(.white)
                                
                                DatePicker("End Time", selection: $endTime, displayedComponents: [.date, .hourAndMinute])
                                    .datePickerStyle(.compact)
                                    .labelsHidden()
                                    .tint(.white)
                                Text("Hours Slept: \(calculatedSleepHours, specifier: "%.1f") hrs")
                                    .foregroundColor(.white.opacity(0.8))
                            }
                        }
                        
                        // Exercise 記錄
                        else if selectedType == .exercise {
                            SectionContainer(title: "Date") {
                                HStack{
                                    DatePicker("Date", selection: $date, displayedComponents: .date)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .tint(.white)
                                        .padding(.vertical, 5)
                                    DatePicker("Start Time", selection: $startTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .tint(.white)
                                    Text("~")
                                        .font(.headline)
                                        .foregroundColor(.black)
                                    DatePicker("End Time", selection: $endTime, displayedComponents: .hourAndMinute)
                                        .datePickerStyle(.compact)
                                        .labelsHidden()
                                        .tint(.white)
                                }
                            }
                            SectionContainer(title: "Exercise") {
                                TextField("Title", text: $title)
                                    .textFieldStyle(RoundedBorderTextFieldStyle())
                                    .padding(.vertical, 5)
                                TipView(inputDataTip, arrowEdge: .bottom)
                                HStack {
                                    Text("Calorie Burn:")
                                        .font(.headline)
                                        .foregroundColor(.white)
                                        .padding(.trailing, 5.0)
                                    TextField("Enter value", text: $value)
                                        .keyboardType(.decimalPad)
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .frame(maxWidth: 100)
                                    Stepper("", value: Binding(
                                        get: { Double(value) ?? 0 },
                                        set: { value = String($0) }
                                    ), step: 10)
                                    .labelsHidden()
                                }
                                .padding(.vertical, 10)
                            }
                        }
                        
                        // 添加按鈕
                        Button(action: addRecord) {
                            Text("Add Record")
                                .font(.headline)
                                .foregroundColor(Color.white) // 设置禁用时的文字颜色
                                .padding()
                                .frame(maxWidth: .infinity)
                                .background(
                                    Group {
                                        if isAddButtonDisabled() {
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
                                .shadow(color: .black.opacity(isAddButtonDisabled() ? 0 : 0.2), radius: 5, x: 0, y: 3) // 禁用时去掉阴影
                        }
                        .disabled(isAddButtonDisabled())
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Add Activity")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                        .shadow(color: .black.opacity(0.3), radius: 5, x: 0, y: 2)
                }
            }
            .onAppear {
                            setupTransparentNavigationBar()
                        }
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    private func setupTransparentNavigationBar() {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithTransparentBackground()
            appearance.backgroundColor = UIColor.clear
            appearance.shadowColor = nil
            UINavigationBar.appearance().standardAppearance = appearance
            UINavigationBar.appearance().scrollEdgeAppearance = appearance
        }
    // 檢查按鈕是否可用
    private func isAddButtonDisabled() -> Bool {
        (selectedType != .sleep && Double(value) ?? 0 <= 0) ||
        (selectedType == .sleep && calculatedSleepHours <= 0) ||
        startTime > endTime
    }
    
    // 添加記錄的處理邏輯
    private func addRecord() {
        let newRecord: ActivityRecord
        if selectedType == .sleep {
            newRecord = ActivityRecord(
                type: selectedType,
                title: "Sleep",
                value: calculatedSleepHours,
                date: startTime,
                startTime: startTime,
                endTime: endTime,
                notes: notes
            )
        } else if selectedType == .hydration {
            guard let newValue = Double(value), newValue > 0 else { return }
            newRecord = ActivityRecord(
                type: selectedType,
                title: "Hydration",
                value: newValue,
                date: date,
                notes: notes
            )
        } else {
            guard let newValue = Double(value), newValue > 0 else { return }
            newRecord = ActivityRecord(
                type: selectedType,
                title: title,
                value: newValue,
                date: date,
                startTime: startTime,
                endTime: endTime,
                notes: notes
            )
        }
        currentUser.activityRecords.append(newRecord)
        modelContext.insert(newRecord)
        dismiss()
    }
}

    // 自定義的 Section 容器
struct SectionContainer<Content: View>: View {
    let title: String
    let content: Content
    
    init(title: String, @ViewBuilder content: () -> Content) {
        self.title = title
        self.content = content()
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
            content
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(12)
                .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
        }
    }
}



struct ActivityDetailView: View {
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss
    @State private var showEditView = false // 用來控制是否顯示編輯畫面
    var record: ActivityRecord
    var goal: Goal?

    let viewActivityDetailsTip = ViewActivityDetailsTip()
    let activityTypeFieldsTip = ActivityTypeFieldsTip()
    let deleteActivityTip = DeleteActivityTip()

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
                        // 擴充 Summary 區域，新增額外資訊
                        VStack(alignment: .leading, spacing: 15) {

                            HStack {
                                ActivityIcon(type: record.type)
                                    .frame(width: 60, height: 60)

                                VStack(alignment: .leading, spacing: 5) {
                                    Text(record.type.rawValue.capitalized)
                                        .font(.title)
                                        .foregroundColor(.white)

                                    Text("Date: \(record.date, style: .date)")
                                        .foregroundColor(.white.opacity(0.8))
                                }
                            }
                            // 新增描述或提示文字
                            Text("Track your daily progress and stay motivated!")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.8))
                        }
                        .padding()
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color.white.opacity(0.2))
                                .shadow(color: .black.opacity(0.2), radius: 10, x: 0, y: 5)
                        )
                        .padding(.horizontal)

                        // 詳細信息區域：增大 DetailRow，填滿空間
                        SectionContainer(title: "Details") {
                            DetailRow(record: record)
                                .padding(5)
                        }

                        // 擴展按鈕區域，並增加其他功能
                        SectionContainer(title: "Actions") {
                            VStack(spacing: 10) {
                                // 編輯按鈕
                                Button(action: {
                                    showEditView = true // 顯示編輯畫面
                                }) {
                                    HStack {
                                        Image(systemName: "pencil")
                                            .font(.headline)
                                        Text("Edit Activity")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(Color.blue.opacity(0.8))
                                    .cornerRadius(12)
                                    .shadow(color: .black.opacity(0.2), radius: 5, x: 0, y: 3)
                                }
                                .sheet(isPresented: $showEditView) {
                                    EditActivityView(record: record) // 傳入活動記錄
                                        .presentationDetents([.fraction(0.7)]) // 控制尺寸
                                        .presentationDragIndicator(.visible) // 顯示拖動指示器
                                }

                                // 刪除按鈕
                                Button(action: deleteRecord) {
                                    HStack {
                                        Image(systemName: "trash")
                                            .font(.headline)
                                        Text("Delete Activity")
                                            .font(.headline)
                                    }
                                    .foregroundColor(.white)
                                    .padding()
                                    .frame(maxWidth: .infinity)
                                    .background(
                                        LinearGradient(
                                            gradient: Gradient(colors: [Color.red, Color.orange]),
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
                    .padding()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Activity Details")
                        .font(.headline)
                        .foregroundColor(.white)
                }
            }
            .onAppear {
                setupTransparentNavigationBar()
            }
        }
    }

    private func deleteRecord() {
        modelContext.delete(record) // 删除记录
        dismiss() // 返回上一页面
    }

    private func setupTransparentNavigationBar() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithTransparentBackground()
        appearance.backgroundColor = UIColor.clear
        appearance.shadowColor = nil
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
}
// MARK: - Helper Views

struct ActivityIcon: View {
    var type: ActivityType

    var body: some View {
        ZStack {
            Circle()
                .fill(type.color.opacity(0.7))

            if type == .hydration {
                Image(systemName: "drop.fill")
                    .foregroundColor(.white)
                    .font(.title)
            } else if type == .sleep {
                Image(systemName: "moon.fill")
                    .foregroundColor(.white)
                    .font(.title)
            } else if type == .exercise {
                Image(systemName: "heart.fill")
                    .foregroundColor(.white)
                    .font(.title)
            }
        }
    }
}

struct DetailRow: View {
    let record: ActivityRecord
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 活動類型標題
            HStack {
                activityIcon(for: record.type)
                    .font(.title2)
                    .foregroundColor(iconColor(for: record.type))
                Text(record.type.rawValue.capitalized)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            // 活動標題
            if record.type == .exercise {
                Text(record.title)
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.8))
            }
            
            // 活動主要數據
            if record.type == .hydration {
                Text("Amount: \(record.value, specifier: "%.0f") ml")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                Text("Time: \(record.date, style: .time)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            } else if record.type == .sleep {
                Text("Start Time: \(record.startTime ?? Date(), style: .time)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                Text("End Time: \(record.endTime ?? Date(), style: .time)")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                Text("Duration: \(record.value, specifier: "%.1f") hrs")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            } else if record.type == .exercise {
                Text("Calories: \(record.value, specifier: "%.0f") kcal")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.9))
                Text("Start Time: \(record.startTime ?? Date(), style: .time)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                Text("End Time: \(record.endTime ?? Date(), style: .time)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
            }
            
            // 備註
            if let notes = record.notes, !notes.isEmpty {
                Text("Notes: \(notes)")
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.6))
                    .padding(.top, 4)
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
    
    // Helper: 活動圖標
    private func activityIcon(for type: ActivityType) -> Image {
        switch type {
        case .hydration:
            return Image(systemName: "drop.fill")
        case .sleep:
            return Image(systemName: "moon.fill")
        case .exercise:
            return Image(systemName: "heart.fill")
        }
    }
    
    // Helper: 圖標顏色
    private func iconColor(for type: ActivityType) -> Color {
        switch type {
        case .hydration:
            return .blue
        case .sleep:
            return .yellow
        case .exercise:
            return .red
        }
    }
}

extension ActivityType {
    var color: Color {
        switch self {
        case .hydration: return .blue
        case .sleep: return .yellow
        case .exercise: return .red
        }
    }
}

struct EditActivityView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var title: String
    @State private var type: ActivityType
    @State private var value: Double
    @State private var startTime: Date
    @State private var endTime: Date
    @State private var notes: String

    var record: ActivityRecord

    init(record: ActivityRecord) {
        self.record = record
        _title = State(initialValue: record.title)
        _type = State(initialValue: record.type)
        _value = State(initialValue: record.value)
        _startTime = State(initialValue: record.startTime ?? Date())
        _endTime = State(initialValue: record.endTime ?? Date())
        _notes = State(initialValue: record.notes ?? "")
    }

    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(
                    gradient: Gradient(colors: [Color.blue.opacity(0.5), Color.purple.opacity(0.5)]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 20) {
                        // 活動資訊
                        SectionContainer(title: "Activity Info") {
                            TextField("Title", text: $title)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .padding(.vertical, 5)
                        }
                        
                        // 詳細資訊
                        SectionContainer(title: "Details") {
                            if type == .hydration {
                                VStack(spacing: 10) {
                                    HStack {
                                        Text("Amount:")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Stepper(value: $value, in: 0...5000, step: 100) {
                                            Text("\(value, specifier: "%.0f") ml")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    TextField("Enter amount (ml)", value: $value, formatter: createDecimalFormatter())
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.decimalPad)
                                }
                            } else if type == .sleep {
                                VStack(spacing: 10) {
                                    HStack {
                                        Text("Duration:")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Stepper(value: $value, in: 0...24, step: 0.1) {
                                            Text("\(value, specifier: "%.1f") hrs")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    TextField("Enter duration (hrs)", value: $value, formatter: createDecimalFormatter())
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.decimalPad)
                                }
                            } else if type == .exercise {
                                VStack(spacing: 10) {
                                    HStack {
                                        Text("Calories:")
                                            .font(.headline)
                                            .foregroundColor(.white)
                                        Stepper(value: $value, in: 0...2000, step: 10) {
                                            Text("\(value, specifier: "%.0f") kcal")
                                                .foregroundColor(.white)
                                        }
                                    }
                                    TextField("Enter calories (kcal)", value: $value, formatter: createDecimalFormatter())
                                        .textFieldStyle(RoundedBorderTextFieldStyle())
                                        .keyboardType(.decimalPad)
                                }
                            }
                        }
                        
                        // 備註
                        SectionContainer(title: "Notes") {
                            TextEditor(text: $notes)
                                .frame(height: 100)
                                .background(Color.white.opacity(0.2))
                                .cornerRadius(8)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(Color.gray.opacity(0.5), lineWidth: 1)
                                )
                        }
                    }
                    .padding()
                }
            }
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Edit Activity")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        saveChanges()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    private func createDecimalFormatter() -> NumberFormatter {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        formatter.minimumFractionDigits = 0
        formatter.maximumFractionDigits = 2 // 限制小数位数
        return formatter
    }

    private func saveChanges() {
        // 更新活動記錄的資料
        record.title = title
        record.type = type
        record.value = value
        record.startTime = type == .hydration ? nil : startTime
        record.endTime = type == .hydration ? nil : endTime
        record.notes = notes

        // 保存數據到 ModelContext
        try? modelContext.save()
        dismiss()
    }
}
