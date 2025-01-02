//
//  Tip.swift
//  01157025_final
//
//  Created by user10 on 2024/12/4.
//

import SwiftUI
import TipKit

// 定義goal提示
struct GoalProgressTip: Tip {
    var title: Text {
        Text("Track Your Goals")
    }
    var message: Text? {
        Text("Use the date filter to view your goals and their progress on specific days.")
    }
    var image: Image? {
        Image(systemName: "calendar")
    }
}

struct ProgressMeaningTip: Tip {
    var title: Text {
        Text("Understand Progress")
    }
    var message: Text? {
        Text("The progress bar shows how close you are to achieving your goal based on your activity records.")
    }
    var image: Image? {
        Image(systemName: "chart.bar.fill")
    }
}

struct AddGoalTip: Tip {
    var title: Text {
        Text("Add New Goals")
    }
    var image: Image? {
        Image(systemName: "plus.circle")
    }
}

//圖表分析提示
struct ChartPickerTip: Tip {
    var title: Text {
        Text("Switch Activity Types")
    }

    var message: Text? {
        Text("Use this picker to view data for exercise, hydration, or sleep for the selected week.")
    }

    var image: Image? {
        Image(systemName: "chart.line.uptrend.xyaxis")
    }
}

struct WeeklySummaryTip: Tip {
    var title: Text {
        Text("View Weekly Summary")
    }

    var message: Text? {
        Text("Check the total and average activity metrics for the week here.")
    }

    var image: Image? {
        Image(systemName: "calendar")
    }
}


//紀錄頁面提示
struct DateRangeTip: Tip {
    var title: Text {
        Text("Filter by Date Range")
    }
    var message: Text? {
        Text("Use the 'From' and 'To' date pickers to filter your activity records by date.")
    }
    var image: Image? {
        Image(systemName: "calendar")
    }
}
// 選擇活動類型提示
struct SelectActivityTypeTip: Tip {
    var title: Text {
        Text("Choose Activity Type")
    }
    var message: Text? {
        Text("Use the segmented control to select the type of activity you want to log: Exercise, Sleep, or Hydration.")
    }
    var image: Image? {
        Image(systemName: "list.bullet")
    }
}

// 輸入數據提示
struct InputDataTip: Tip {
    var title: Text {
        Text("Input Your Data")
    }
    var message: Text? {
        Text("Enter your activity details, such as the amount of water, calories burned, or sleep hours.")
    }
    var image: Image? {
        Image(systemName: "pencil")
    }
}

// 睡眠時間提示
struct SleepTimeTip: Tip {
    var title: Text {
        Text("Set Sleep Time")
    }
    var message: Text? {
        Text("Ensure the start time is earlier than the end time to calculate your sleep hours correctly.")
    }
    var image: Image? {
        Image(systemName: "bed.double.fill")
    }
}

// 完成新增記錄提示
struct AddRecordTip: Tip {
    var title: Text {
        Text("Save Your Activity")
    }
    var message: Text? {
        Text("Tap the 'Add Record' button to save your activity. Make sure all fields are valid.")
    }
    var image: Image? {
        Image(systemName: "checkmark.circle")
    }
}

// 查看活動詳細信息提示
struct ViewActivityDetailsTip: Tip {
    var title: Text {
        Text("View Activity Details")
    }
    var message: Text? {
        Text("Here you can see the detailed information of the activity you logged, including type, date, and specific values.")
    }
    var image: Image? {
        Image(systemName: "info.circle")
    }
}

// 理解活動類型提示
struct ActivityTypeFieldsTip: Tip {
    var title: Text {
        Text("Activity Type Specifics")
    }
    var message: Text? {
        Text("Depending on the activity type, you will see additional details, such as water amount for hydration or duration for sleep.")
    }
    var image: Image? {
        Image(systemName: "list.bullet.rectangle")
    }
}

// 刪除記錄提示
struct DeleteActivityTip: Tip {
    var title: Text {
        Text("Delete an Activity")
    }
    var message: Text? {
        Text("You can remove this activity from your records by tapping the 'Delete Activity' button. This action cannot be undone.")
    }
    var image: Image? {
        Image(systemName: "trash")
    }
}
