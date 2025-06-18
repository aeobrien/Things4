import SwiftUI
import Things4

struct RepeatModal: View {
    @Binding var todo: ToDo
    @EnvironmentObject var store: DatabaseStore
    @Environment(\.dismiss) private var dismiss
    
    @State private var repeatType: RepeatType = .after_completion
    @State private var frequency: Frequency = .daily
    @State private var interval: Int = 1
    @State private var afterCompletionUnit: AfterCompletionUnit = .day
    @State private var selectedWeekdays: Set<DayOfWeek> = []
    @State private var monthlyDay: Int = 1
    @State private var monthlyType: MonthlyType = .day
    @State private var monthlyWeekday: DayOfWeek = .monday
    @State private var yearlyDay: Int = 1
    @State private var yearlyType: MonthlyType = .day
    @State private var yearlyWeekday: DayOfWeek = .monday
    @State private var yearlyMonth: Int = 1
    @State private var nextDate = Date()
    @State private var endType: EndType = .never
    @State private var endAfterCount: Int = 10
    @State private var endOnDate = Date()
    @State private var addReminders = false
    @State private var addDeadlines = false
    
    enum AfterCompletionUnit: String, CaseIterable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }
    
    enum MonthlyType: String, CaseIterable {
        case day = "Day"
        case weekday = "Weekday"
    }
    
    enum EndType: String, CaseIterable {
        case never = "Never"
        case after = "After"
        case onDate = "On Date"
    }
    
    var body: some View {
        VStack(spacing: 0) {
            // Title
            HStack {
                Text("Repeat")
                    .font(.title2)
                    .fontWeight(.semibold)
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.title2)
                        .foregroundColor(.secondary)
                }
                .buttonStyle(.plain)
            }
            .padding()
            .background(Color(NSColor.controlBackgroundColor))
            
            Divider()
            
            // Content
            ScrollView {
                VStack(alignment: .leading, spacing: 20) {
                    // Repeat Type
                    HStack {
                        Text("Repeat")
                        Picker("", selection: $repeatType) {
                            Text("After Completion").tag(RepeatType.after_completion)
                            Text("Daily").tag(RepeatType.on_schedule)
                            Text("Weekly").tag(RepeatType.on_schedule)
                            Text("Monthly").tag(RepeatType.on_schedule)
                            Text("Yearly").tag(RepeatType.on_schedule)
                        }
                        .pickerStyle(.menu)
                        .onChange(of: repeatType) { newValue in
                            if newValue == .on_schedule && frequency == .daily {
                                // Already set
                            } else if repeatType == .after_completion {
                                frequency = .daily
                            }
                        }
                    }
                    
                    // After Completion Settings
                    if repeatType == .after_completion {
                        HStack {
                            TextField("", value: $interval, format: .number)
                                .frame(width: 60)
                                .textFieldStyle(.roundedBorder)
                            Picker("", selection: $afterCompletionUnit) {
                                ForEach(AfterCompletionUnit.allCases, id: \.self) { unit in
                                    Text(unit.rawValue + (interval == 1 ? "" : "s")).tag(unit)
                                }
                            }
                            .pickerStyle(.menu)
                            Text("after previous item is checked off")
                                .foregroundColor(.secondary)
                        }
                    }
                    
                    // Regular Schedule Settings
                    if repeatType == .on_schedule {
                        VStack(alignment: .leading, spacing: 16) {
                            // Frequency selection (for regular type)
                            Picker("Frequency", selection: $frequency) {
                                Text("Daily").tag(Frequency.daily)
                                Text("Weekly").tag(Frequency.weekly)
                                Text("Monthly").tag(Frequency.monthly)
                                Text("Yearly").tag(Frequency.yearly)
                            }
                            .pickerStyle(.segmented)
                            
                            // Interval and specifics
                            switch frequency {
                            case .daily:
                                HStack {
                                    Text("Every")
                                    TextField("", value: $interval, format: .number)
                                        .frame(width: 60)
                                        .textFieldStyle(.roundedBorder)
                                    Text(interval == 1 ? "day" : "days")
                                }
                                
                            case .weekly:
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Every")
                                        TextField("", value: $interval, format: .number)
                                            .frame(width: 60)
                                            .textFieldStyle(.roundedBorder)
                                        Text(interval == 1 ? "week on" : "weeks on")
                                    }
                                    
                                    HStack(spacing: 8) {
                                        ForEach(DayOfWeek.allCases, id: \.self) { day in
                                            Toggle(isOn: Binding(
                                                get: { selectedWeekdays.contains(day) },
                                                set: { isOn in
                                                    if isOn {
                                                        selectedWeekdays.insert(day)
                                                    } else {
                                                        selectedWeekdays.remove(day)
                                                    }
                                                }
                                            )) {
                                                Text(String(day.shortName.prefix(1)))
                                                    .frame(width: 20)
                                            }
                                            .toggleStyle(.button)
                                        }
                                    }
                                }
                                
                            case .monthly:
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Every")
                                        TextField("", value: $interval, format: .number)
                                            .frame(width: 60)
                                            .textFieldStyle(.roundedBorder)
                                        Text(interval == 1 ? "month on the" : "months on the")
                                    }
                                    
                                    HStack {
                                        Picker("", selection: $monthlyDay) {
                                            ForEach(1...31, id: \.self) { day in
                                                Text("\(day)").tag(day)
                                            }
                                            Text("Last").tag(32)
                                        }
                                        .pickerStyle(.menu)
                                        
                                        Picker("", selection: $monthlyType) {
                                            Text("Day").tag(MonthlyType.day)
                                            ForEach(DayOfWeek.allCases, id: \.self) { day in
                                                Text(day.name).tag(MonthlyType.weekday)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        .onChange(of: monthlyType) { newValue in
                                            if newValue == .weekday && monthlyWeekday == .monday {
                                                monthlyWeekday = DayOfWeek.allCases.first!
                                            }
                                        }
                                    }
                                }
                                
                            case .yearly:
                                VStack(alignment: .leading, spacing: 12) {
                                    HStack {
                                        Text("Every")
                                        TextField("", value: $interval, format: .number)
                                            .frame(width: 60)
                                            .textFieldStyle(.roundedBorder)
                                        Text(interval == 1 ? "year on the" : "years on the")
                                    }
                                    
                                    HStack {
                                        Picker("", selection: $yearlyDay) {
                                            ForEach(1...31, id: \.self) { day in
                                                Text("\(day)").tag(day)
                                            }
                                            Text("Last").tag(32)
                                        }
                                        .pickerStyle(.menu)
                                        
                                        Picker("", selection: $yearlyType) {
                                            Text("Day").tag(MonthlyType.day)
                                            ForEach(DayOfWeek.allCases, id: \.self) { day in
                                                Text(day.name).tag(MonthlyType.weekday)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                        
                                        Text("in")
                                        
                                        Picker("", selection: $yearlyMonth) {
                                            ForEach(1...12, id: \.self) { month in
                                                Text(Calendar.current.monthSymbols[month - 1]).tag(month)
                                            }
                                        }
                                        .pickerStyle(.menu)
                                    }
                                }
                            }
                            
                            // Next date
                            HStack {
                                Text("Next")
                                DatePicker("", selection: $nextDate, displayedComponents: .date)
                                    .datePickerStyle(.compact)
                            }
                            
                            // Preview dates
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Following dates:")
                                    .font(.caption)
                                    .foregroundColor(.secondary)
                                ForEach(previewDates(), id: \.self) { date in
                                    Text(date, style: .date)
                                        .font(.caption)
                                        .foregroundColor(.secondary)
                                }
                            }
                            .padding(.top, 8)
                        }
                    }
                    
                    // End settings
                    HStack {
                        Text("Ends")
                        Picker("", selection: $endType) {
                            ForEach(EndType.allCases, id: \.self) { type in
                                Text(type.rawValue).tag(type)
                            }
                        }
                        .pickerStyle(.menu)
                        
                        switch endType {
                        case .never:
                            EmptyView()
                        case .after:
                            TextField("", value: $endAfterCount, format: .number)
                                .frame(width: 60)
                                .textFieldStyle(.roundedBorder)
                            Text("times")
                        case .onDate:
                            DatePicker("", selection: $endOnDate, displayedComponents: .date)
                                .datePickerStyle(.compact)
                        }
                    }
                    
                    Divider()
                    
                    // Options
                    VStack(alignment: .leading, spacing: 12) {
                        Toggle("Add Reminders", isOn: $addReminders)
                        Toggle("Add Deadlines", isOn: $addDeadlines)
                    }
                    
                    // Buttons
                    HStack {
                        Button("Cancel") {
                            dismiss()
                        }
                        .keyboardShortcut(.escape)
                        
                        Spacer()
                        
                        Button("Save") {
                            saveRepeatRule()
                            dismiss()
                        }
                        .keyboardShortcut(.return)
                        .buttonStyle(.borderedProminent)
                    }
                }
                .padding()
            }
        }
        .frame(width: 500, height: 600)
        .onAppear {
            loadExistingRule()
        }
    }
    
    private func previewDates() -> [Date] {
        // Generate preview dates based on current settings
        var dates: [Date] = []
        var currentDate = nextDate
        
        for _ in 0..<4 {
            dates.append(currentDate)
            
            switch frequency {
            case .daily:
                currentDate = Calendar.current.date(byAdding: .day, value: interval, to: currentDate) ?? currentDate
            case .weekly:
                currentDate = Calendar.current.date(byAdding: .weekOfYear, value: interval, to: currentDate) ?? currentDate
            case .monthly:
                currentDate = Calendar.current.date(byAdding: .month, value: interval, to: currentDate) ?? currentDate
            case .yearly:
                currentDate = Calendar.current.date(byAdding: .year, value: interval, to: currentDate) ?? currentDate
            }
        }
        
        return dates
    }
    
    private func loadExistingRule() {
        // Load existing repeat rule if todo has one
        if let ruleID = todo.repeatRuleID,
           let rule = store.database.repeatRules.first(where: { $0.id == ruleID }) {
            repeatType = rule.type
            frequency = rule.frequency
            interval = rule.interval
            if let weekdays = rule.weekdays {
                selectedWeekdays = Set(weekdays)
            }
        }
    }
    
    private func saveRepeatRule() {
        // Create or update repeat rule
        let rule = RepeatRule(
            type: repeatType,
            frequency: frequency,
            interval: interval,
            weekdays: frequency == .weekly ? Array(selectedWeekdays) : nil,
            templateData: Data() // Would encode the todo as template
        )
        
        if let existingIndex = store.database.repeatRules.firstIndex(where: { $0.id == todo.repeatRuleID }) {
            store.database.repeatRules[existingIndex] = rule
        } else {
            store.database.repeatRules.append(rule)
            if let todoIndex = store.database.toDos.firstIndex(where: { $0.id == todo.id }) {
                store.database.toDos[todoIndex].repeatRuleID = rule.id
            }
        }
        
        store.save()
    }
}

// Extension for day names
extension DayOfWeek {
    var name: String {
        switch self {
        case .sunday: return "Sunday"
        case .monday: return "Monday"
        case .tuesday: return "Tuesday"
        case .wednesday: return "Wednesday"
        case .thursday: return "Thursday"
        case .friday: return "Friday"
        case .saturday: return "Saturday"
        }
    }
    
    var shortName: String {
        switch self {
        case .sunday: return "Sun"
        case .monday: return "Mon"
        case .tuesday: return "Tue"
        case .wednesday: return "Wed"
        case .thursday: return "Thu"
        case .friday: return "Fri"
        case .saturday: return "Sat"
        }
    }
}

#Preview {
    RepeatModal(todo: .constant(ToDo(title: "Sample")))
        .environmentObject(DatabaseStore())
}