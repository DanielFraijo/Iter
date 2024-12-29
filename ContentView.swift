import SwiftUI
import Combine

struct DailyInteraction: Codable {
    var day: Date // Changed to Date for better tracking
    var interacted: Bool
}

struct Habit: Identifiable, Codable {
    let id = UUID()
    var name: String
    var dailyInteractions: [DailyInteraction] = []
}

class HabitModel: ObservableObject {
    @Published var habits: [Habit] = [Habit(name: "Water Intake")]
    
    // Constructor to load data from UserDefaults
    init() {
        if let data = UserDefaults.standard.data(forKey: "habits") {
            do {
                habits = try JSONDecoder().decode([Habit].self, from: data)
            } catch {
                print("Failed to decode habits from UserDefaults: \(error)")
            }
        }
    }
    
    func addHabit(name: String) {
        habits.append(Habit(name: name))
        save()
    }
    
    // Toggle interaction state for a specific day of a habit
    func toggleInteraction(for habit: Habit, on date: Date) {
        if let index = habits.firstIndex(where: { $0.id == habit.id }) {
            if let interactionIndex = habits[index].dailyInteractions.firstIndex(where: { Calendar.current.isDate($0.day, inSameDayAs: date) }) {
                habits[index].dailyInteractions[interactionIndex].interacted.toggle()
            } else {
                habits[index].dailyInteractions.append(DailyInteraction(day: date, interacted: true))
            }
            save()
        }
    }
    
    // Save to UserDefaults, now including daily interaction states
    private func save() {
        do {
            let encodedData = try JSONEncoder().encode(habits)
            UserDefaults.standard.set(encodedData, forKey: "habits")
        } catch {
            print("Failed to encode habits to UserDefaults: \(error)")
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
                                            Text(String(dayNumber))
                                                .font(.headline)
                                        }
                                        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                                        .background(interacted ? Color.green : Color.white.opacity(0.1))
                                        .cornerRadius(20)
                                        .foregroundColor(interacted ? .black : .white)
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    .padding(.bottom)
                }
            }

            // Input for new habit
            HStack {
                TextField("Enter new habit", text: $newHabitName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
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

// Helper extension to get the start of the week from any date remains unchanged
extension Date {
    var startOfWeek: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }
}

// New Habit Detail View
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
            
            NavigationLink(destination: HabitSummaryView(year: Calendar.current.component(.year, from: Date()))) {
                Text("View Summary")
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

struct HabitSummaryView: View {
    @EnvironmentObject var habitModel: HabitModel
    let year: Int
    
    var body: some View {
        VStack {
            Text("Habit Summary for \(year)")
                .font(.title)
                .foregroundColor(.white)
            
            let calendar = Calendar.current
            let startDate = DateComponents(year: year, month: 1, day: 1).date!
            let daysInYear = isLeapYear(year) ? 366 : 365 // Changed here

            ScrollView {
                VStack(spacing: 10) {
                    ForEach(1...12, id: \.self) { month in
                        Text(calendar.monthSymbols[month - 1])
                            .font(.headline)
                            .foregroundColor(.white)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 2), count: 7), spacing: 2) {
                            ForEach(1...daysInMonth(month: month, year: year), id: \.self) { day in
                                let date = calendar.date(byAdding: .day, value: day - 1, to: calendar.date(from: DateComponents(year: year, month: month, day: 1))!)!
                                let interacted = habitModel.habits.flatMap { $0.dailyInteractions }.contains { Calendar.current.isDate($0.day, inSameDayAs: date) && $0.interacted }
                                
                                Rectangle()
                                    .fill(interacted ? Color.green : Color.gray)
                                    .frame(width: 20, height: 20)
                            }
                        }
                    }
                }
            }
        }
        .background(Color.black.edgesIgnoringSafeArea(.all))
    }
    
    func daysInMonth(month: Int, year: Int) -> Int {
        let dateComponents = DateComponents(year: year, month: month)
        if let date = Calendar.current.date(from: dateComponents) {
            return Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 0
        }
        return 0
    }
    
    func isLeapYear(_ year: Int) -> Bool {
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }
}
    
    func daysInMonth(month: Int, year: Int) -> Int {
        let dateComponents = DateComponents(year: year, month: month)
        if let date = Calendar.current.date(from: dateComponents) {
            return Calendar.current.range(of: .day, in: .month, for: date)?.count ?? 0
        }
        return 0
    }
    
    func isLeapYear(_ year: Int) -> Bool {
        return (year % 4 == 0 && year % 100 != 0) || (year % 400 == 0)
    }

// Placeholder for To Do View
struct ToDoView: View {
    var body: some View {
        Text("To Do Screen")
            .font(.largeTitle)
            .foregroundColor(.white)
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
}

struct CalorieIntakeView: View {
    var body: some View {
        Text("Calorie Intake Screen")
            .font(.largeTitle)
            .foregroundColor(.white)
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
    var body: some View {
        Text("Finances Screen")
            .font(.largeTitle)
            .foregroundColor(.white)
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
