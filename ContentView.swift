import SwiftUI
import Combine
import Charts

struct DailyInteraction: Codable {
    var day: Date
    var interacted: Bool
}

struct Habit: Identifiable, Codable {
    let id = UUID()
    var name: String
    var dailyInteractions: [DailyInteraction] = []
}

struct Task: Identifiable, Codable {
    let id = UUID()
    var title: String
    var note: String = ""
}

struct CalorieGoal: Codable {
    var dailyGoal: Int
}

struct FinancialData: Codable {
    var monthlyIncome: Double
}

struct CalorieData: Codable {
    var goal: Int
    var consumed: Int
    var burned: Int
    
    var remaining: Int {
        goal - (consumed - burned)
    }
}

class HabitModel: ObservableObject {
    @Published var habits: [Habit] = []
    @Published var tasks: [Task] = []
    @Published var calorieGoal = CalorieGoal(dailyGoal: 0)
    @Published var financialData = FinancialData(monthlyIncome: 0.0)
    @Published var calorieData = CalorieData(goal: 0, consumed: 0, burned: 0)
    
    // Constructor to load data from UserDefaults
    init() {
        loadHabits()
        loadTasks()
        loadCalorieGoal()
        loadFinancialData()
        loadCalorieData() // Load calorie data
    }
    
    // Habits methods
    func addHabit(name: String) {
        habits.append(Habit(name: name))
        saveHabits()
    }
    
    func toggleInteraction(for habit: Habit, on date: Date) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            if let interactionIndex = habits[index].dailyInteractions.firstIndex(where: { Calendar.current.isDate($0.day, inSameDayAs: date) }) {
                habits[index].dailyInteractions[interactionIndex].interacted.toggle()
            } else {
                habits[index].dailyInteractions.append(DailyInteraction(day: date, interacted: true))
            }
            saveHabits()
        }
    }
    
    func deleteHabit(_ habit: Habit) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            habits.remove(at: index)
            saveHabits()
        }
    }
    
    private func saveHabits() {
        do {
            let data = try JSONEncoder().encode(habits)
            UserDefaults.standard.set(data, forKey: "habits")
        } catch {
            print("Failed to encode habits to UserDefaults: \(error)")
        }
    }
    
    private func loadHabits() {
        if let data = UserDefaults.standard.data(forKey: "habits") {
            do {
                habits = try JSONDecoder().decode([Habit].self, from: data)
            } catch {
                print("Failed to decode habits from UserDefaults: \(error)")
            }
        }
    }
    
    // Tasks methods
    func addTask(title: String, note: String = "") {
        tasks.append(Task(title: title, note: note))
        saveTasks()
    }
    
    func removeTasks(at offsets: IndexSet) {
        tasks.remove(atOffsets: offsets)
        saveTasks()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    private func saveTasks() {
        do {
            let data = try JSONEncoder().encode(tasks)
            UserDefaults.standard.set(data, forKey: "tasks")
        } catch {
            print("Failed to encode tasks to UserDefaults: \(error)")
        }
    }
    
    private func loadTasks() {
        if let data = UserDefaults.standard.data(forKey: "tasks") {
            do {
                tasks = try JSONDecoder().decode([Task].self, from: data)
            } catch {
                print("Failed to decode tasks from UserDefaults: \(error)")
            }
        }
    }
    
    // Calorie Goal methods
    func setCalorieGoal(_ goal: Int) {
        calorieGoal.dailyGoal = goal
        calorieData.goal = goal
        saveCalorieData()
    }
    
    func addConsumedCalories(_ calories: Int) {
        calorieData.consumed += calories
        saveCalorieData()
    }
    
    func addBurnedCalories(_ calories: Int) {
        calorieData.burned += calories
        saveCalorieData()
    }
    
    fileprivate func saveCalorieData() {
        do {
            let data = try JSONEncoder().encode(calorieData)
            UserDefaults.standard.set(data, forKey: "calorieData")
        } catch {
            print("Failed to encode calorie data to UserDefaults: \(error)")
        }
    }
    
    private func loadCalorieData() {
        if let data = UserDefaults.standard.data(forKey: "calorieData") {
            do {
                calorieData = try JSONDecoder().decode(CalorieData.self, from: data)
            } catch {
                print("Failed to decode calorie data from UserDefaults: \(error)")
            }
        }
    }
    
    private func saveCalorieGoal() {
        do {
            let data = try JSONEncoder().encode(calorieGoal)
            UserDefaults.standard.set(data, forKey: "calorieGoal")
        } catch {
            print("Failed to encode calorie goal to UserDefaults: \(error)")
        }
    }
    
    private func loadCalorieGoal() {
        if let data = UserDefaults.standard.data(forKey: "calorieGoal") {
            do {
                calorieGoal = try JSONDecoder().decode(CalorieGoal.self, from: data)
            } catch {
                print("Failed to decode calorie goal from UserDefaults: \(error)")
            }
        }
    }
    
    // Financial Data methods
    func setMonthlyIncome(_ income: Double) {
        financialData.monthlyIncome = income
        saveFinancialData()
    }
    
    private func saveFinancialData() {
        do {
            let data = try JSONEncoder().encode(financialData)
            UserDefaults.standard.set(data, forKey: "financialData")
        } catch {
            print("Failed to encode financial data to UserDefaults: \(error)")
        }
    }
    
    private func loadFinancialData() {
        if let data = UserDefaults.standard.data(forKey: "financialData") {
            do {
                financialData = try JSONDecoder().decode(FinancialData.self, from: data)
            } catch {
                print("Failed to decode financial data from UserDefaults: \(error)")
            }
        }
    }
}

struct YourApp: App {
    @StateObject private var habitModel = HabitModel()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(habitModel)
        }
    }
}

struct ContentView: View {
    var body: some View {
        NavigationView {
            ZStack {
                // Background color set to black
                Color.black.edgesIgnoringSafeArea(.all)
                
                VStack {
                    Spacer()
                    
                    // Each window stacked vertically
                    NavigationLink(destination: HabitsView()) {
                        SectionView(title: "Habits", imageName: "star.fill")
                    }
                    NavigationLink(destination: ToDoView()) {
                        SectionView(title: "To Do", imageName: "list.bullet")
                    }
                    NavigationLink(destination: CalorieIntakeView()) {
                        SectionView(title: "Calorie Intake", imageName: "bolt")
                    }
                    NavigationLink(destination: FinancesView()) {
                        SectionView(title: "Finances", imageName: "dollarsign.circle")
                    }
                    
                    Spacer()
                }
                .padding()
            }
            .navigationTitle("Dashboard")
            .navigationBarTitleDisplayMode(.inline)
        }
        .tint(.white) // Set back button and navigation link colors to white for the main view
    }
}

struct SectionView: View {
    let title: String
    let imageName: String
    
    var body: some View {
        VStack {
            // White image icon
            Image(systemName: imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 50, height: 50)
                .foregroundColor(.white)
            // White title text
            Text(title)
                .font(.headline)
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, minHeight: 100)
        .background(Color.black) // Matches the overall background color
        .cornerRadius(20)
        .overlay(
            RoundedRectangle(cornerRadius: 20)
                .stroke(Color.white, lineWidth: 1) // White border for contrast
        )
        .padding(.horizontal) // Add padding to avoid edge collisions
    }
}

struct HabitsView: View {
    @EnvironmentObject var habitModel: HabitModel
    @State private var newHabitName = ""
    @State private var currentDate = Date()

    var body: some View {
        VStack {
            // List of habits
            ScrollView {
                ForEach(habitModel.habits) { habit in
                    NavigationLink(destination: HabitDetailView(habit: habit)) {
                        VStack {
                            // Habit name
                            Text(habit.name)
                                .font(.title)
                                .padding()
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .background(Color.black)
                                .cornerRadius(10)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 1)
                                )
                            
                            // Days of the week with dates for each habit
                            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 5) {
                                ForEach(0..<8) { index in
                                    let date = Calendar.current.date(byAdding: .day, value: index, to: currentDate.startOfWeek)!
                                    let day = Calendar.current.component(.weekday, from: date) - 1
                                    let dayAbbreviation = Calendar.current.shortWeekdaySymbols[day]
                                    let dayNumber = Calendar.current.component(.day, from: date)
                                    let interacted = habit.dailyInteractions.first(where: { Calendar.current.isDate($0.day, inSameDayAs: date) })?.interacted ?? false
                                    
                                    Button(action: {
                                        habitModel.toggleInteraction(for: habit, on: date)
                                    }) {
                                        VStack {
                                            Text(dayAbbreviation)
                                                .font(.caption)
                                                .foregroundColor(interacted ? .black : .white)
                                            Text(String(dayNumber))
                                                .font(.headline)
                                                .foregroundColor(interacted ? .black : .white)
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                                        .background(interacted ? Color.green : Color.white.opacity(0.1))
                                        .cornerRadius(20)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(action: { habitModel.deleteHabit(habit) }) {
                            Label("Delete", systemImage: "trash")
                        }
                        .tint(.red)
                    }
                    .padding(.bottom)
                }
            }

            // Input for new habit
            HStack {
                TextField("Enter new habit", text: $newHabitName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.white)
                Button(action: {
                    habitModel.addHabit(name: newHabitName)
                    newHabitName = ""
                }) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Habits")
                    .foregroundColor(.white)
            }
            ToolbarItem(placement: .navigationBarTrailing) {
                Text(DateFormatter.localizedString(from: currentDate, dateStyle: .medium, timeStyle: .none))
                    .foregroundColor(.white)
            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarBackButtonHidden(false)
        .onAppear {
            self.currentDate = Date()
        }
    }
}

// Helper extension to get the start of the week from any date
extension Date {
    var startOfWeek: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }
}

// Habit Detail View
struct HabitDetailView: View {
    let habit: Habit
    
    var body: some View {
        VStack {
            Text(habit.name)
                .font(.largeTitle)
                .foregroundColor(.white)
            
            // Here you can add more content or interaction related to the habit
            Text("Details for \(habit.name)")
                .font(.body)
                .foregroundColor(.white)
            
            NavigationLink(destination: HabitContributionView(habit: habit)) {
                Text("View Contribution")
                    .padding()
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(habit.name)
                    .foregroundColor(.white)
            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct HabitContributionView: View {
    let habit: Habit
    @State private var year: Int = Calendar.current.component(.year, from: Date())
    
    var body: some View {
        VStack {
            Text("\(habit.name) - \(year)")
                .font(.title)
                .foregroundColor(.white)
            
            Picker("Year", selection: $year) {
                ForEach(2020...year, id: \.self) { year in
                    Text("\(year)")
                        .foregroundColor(.white)
                }
            }
            .pickerStyle(SegmentedPickerStyle())
            .padding()
            
            ScrollView {
                VStack {
                    HStack {
                        ForEach(Calendar.current.shortWeekdaySymbols, id: \.self) { day in
                            Text(day)
                                .frame(maxWidth: .infinity)
                                .font(.caption)
                                .foregroundColor(.white)
                        }
                    }
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 1), count: 7), spacing: 1) {
                        ForEach(daysInYear(year), id: \.self) { date in
                            let interacted = habit.dailyInteractions.contains { interaction in
                                let interactionDay = Calendar.current.date(from: Calendar.current.dateComponents([.year, .month, .day], from: interaction.day)) ?? Date.distantPast
                                return Calendar.current.isDate(date, inSameDayAs: interactionDay) && interaction.interacted
                            }
                            Rectangle()
                                .fill(interacted ? Color.green : Color.gray.opacity(0.2))
                                .frame(width: 20, height: 20)
                                .overlay(
                                    RoundedRectangle(cornerRadius: 2)
                                        .stroke(Color.white.opacity(0.3), lineWidth: 0.5)
                                )
                                .onTapGesture {
                                    print("Interacted on: \(date)")
                                }
                        }
                    }
                    .padding()
                }
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    private func daysInYear(_ year: Int) -> [Date] {
        var dates: [Date] = []
        let calendar = Calendar.current
        var date = DateComponents(year: year, month: 1, day: 1).date!
        while calendar.component(.year, from: date) == year {
            dates.append(date)
            date = calendar.date(byAdding: .day, value: 1, to: date) ?? date
        }
        return dates
    }
}

struct ToDoView: View {
    @EnvironmentObject var habitModel: HabitModel
    @State private var newTaskTitle = ""
    @State private var selectedTask: Task?
    @State private var isEditing = false
    @State private var editedNote = ""

    var body: some View {
        VStack {
            List {
                ForEach(habitModel.tasks) { task in
                    NavigationLink(destination: TaskDetailView(task: task, onSave: habitModel.updateTask)) {
                        HStack {
                            Text(task.title)
                                .foregroundColor(.white)
                            Spacer()
                            if !task.note.isEmpty {
                                Image(systemName: "note.text")
                                    .foregroundColor(.blue)
                            }
                        }
                    }
                }
                .onDelete(perform: habitModel.removeTasks)
                .listRowBackground(Color.black)
            }
            .listStyle(InsetGroupedListStyle())
            .background(Color.black)
            
            HStack {
                TextField("New Task", text: $newTaskTitle)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.white)
                Button(action: addTask) {
                    Image(systemName: "plus.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("To Do")
                    .foregroundColor(.white)
            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
    
    private func addTask() {
        if !newTaskTitle.isEmpty {
            habitModel.addTask(title: newTaskTitle)
            newTaskTitle = ""
        }
    }
}

struct TaskDetailView: View {
    let task: Task
    var onSave: (Task) -> Void
    @State private var note = ""

    var body: some View {
        Form {
            TextField("Title", text: Binding(
                get: { task.title },
                set: { onSave(Task(title: $0, note: note)) }
            ))
            .foregroundColor(.white)
            
            TextEditor(text: $note)
                .frame(minHeight: 200)
                .border(Color.gray, width: 1)
                .foregroundColor(.white)
                .onChange(of: note) { newValue in
                    onSave(Task(title: task.title, note: newValue))
                }
                .onAppear {
                    self.note = task.note
                }
        }
        .navigationTitle(task.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text(task.title)
                    .foregroundColor(.white)
            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct CalorieIntakeView: View {
    @EnvironmentObject var habitModel: HabitModel
    @State private var goalInput = ""
    @State private var consumedInput = ""
    @State private var burnedInput = ""

    var body: some View {
        VStack {
            // Input fields for setting goal, consumed, and burned calories
            HStack {
                TextField("Goal", text: $goalInput)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.white)
                Button("Set") {
                    if let goal = Int(goalInput) {
                        habitModel.setCalorieGoal(goal)
                        goalInput = ""
                    }
                }
            }
            .padding()

            HStack {
                TextField("Consumed", text: $consumedInput)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.white)
                Button("Add") {
                    if let calories = Int(consumedInput) {
                        habitModel.addConsumedCalories(calories)
                        consumedInput = ""
                    }
                }
            }
            .padding()

            HStack {
                TextField("Burned", text: $burnedInput)
                    .keyboardType(.numberPad)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .foregroundColor(.white)
                Button("Add") {
                    if let calories = Int(burnedInput) {
                        habitModel.addBurnedCalories(calories)
                        burnedInput = ""
                    }
                }
            }
            .padding()
            
            // Visual Representation
            VStack {
                Text("Calories Left: \(max(habitModel.calorieData.remaining, 0))")
                    .foregroundColor(.white)
                
                Chart {
                    BarMark(
                        x: .value("Category", "Goal"),
                        y: .value("Calories", habitModel.calorieData.goal)
                    )
                    .foregroundStyle(.blue)
                    
                    BarMark(
                        x: .value("Category", "Consumed"),
                        y: .value("Calories", habitModel.calorieData.consumed)
                    )
                    .foregroundStyle(.red)
                    
                    BarMark(
                        x: .value("Category", "Burned"),
                        y: .value("Calories", habitModel.calorieData.burned)
                    )
                    .foregroundStyle(.green)
                }
                .frame(height: 200)
            }
            
            // Reset button
            Button("Reset Today's Data") {
                habitModel.calorieData.consumed = 0
                habitModel.calorieData.burned = 0
                habitModel.saveCalorieData()
            }
            .padding()
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Calorie Intake")
                    .foregroundColor(.white)
            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

struct FinancesView: View {
    @EnvironmentObject var habitModel: HabitModel
    @State private var inputIncome = ""

    var body: some View {
        VStack {
            TextField("Monthly Income", text: $inputIncome)
                .keyboardType(.decimalPad)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .foregroundColor(.white)
                .padding()
                .onChange(of: inputIncome) { newValue in
                    if let income = Double(newValue) {
                        habitModel.setMonthlyIncome(income)
                    }
                }
            
            Text("Current Monthly Income: $\(String(format: "%.2f", habitModel.financialData.monthlyIncome))")
                .foregroundColor(.white)
                .padding()
            
            // Here you can add more financial tracking features.
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color.black.edgesIgnoringSafeArea(.all))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Finances")
                    .foregroundColor(.white)
            }
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
    }
}

#Preview {
    ContentView()
        .environmentObject(HabitModel())
}
