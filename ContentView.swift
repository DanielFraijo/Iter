import SwiftUI

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
                    NavigationLink(destination: CalendarView()) {
                        SectionView(title: "Calendar", imageName: "calendar")
                    }
                    NavigationLink(destination: CalorieIntakeView()) {
                        SectionView(title: "Calorie Intake", imageName: "fork.knife")
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

struct Habit: Identifiable {
    let id = UUID()
    var name: String
}

struct HabitsView: View {
    @State private var currentDate = Date()
    @State private var habits = [Habit(name: "Water Intake")]  // Initial habit
    @State private var newHabitName = ""

    var body: some View {
        VStack {
            // List of habits
            ScrollView {
                ForEach(habits) { habit in
                    VStack {
                        // Habit name
                        Text(habit.name)
                            .font(.title)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.black)
                            .cornerRadius(10)
                        
                        // Days of the week with dates for each habit
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 8), spacing: 5) {
                            ForEach(0..<8) { index in
                                let date = Calendar.current.date(byAdding: .day, value: index, to: currentDate.startOfWeek)!
                                let day = Calendar.current.component(.weekday, from: date)
                                let dayAbbreviation = Calendar.current.shortWeekdaySymbols[day - 1]
                                let dayNumber = Calendar.current.component(.day, from: date)
                                
                                VStack {
                                    Text(dayAbbreviation)
                                        .font(.caption)
                                    Text(String(dayNumber))
                                        .font(.headline)
                                }
                                .frame(minWidth: 0, maxWidth: .infinity, minHeight: 50)
                                .background(Color.white.opacity(0.1))
                                .cornerRadius(8)
                            }
                        }
                        .padding()
                    }
                    .padding(.bottom)
                }
            }

            // Input for new habit
            HStack {
                TextField("Enter new habit", text: $newHabitName)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: addHabit) {
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
        }
        .toolbarBackground(Color.black, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .navigationBarBackButtonHidden(false)
    }

    private func addHabit() {
        if !newHabitName.isEmpty {
            habits.append(Habit(name: newHabitName))
            newHabitName = ""
        }
    }
}

// Helper extension to get the start of the week from any date
extension Date {
    var startOfWeek: Date {
        return Calendar.current.date(from: Calendar.current.dateComponents([.yearForWeekOfYear, .weekOfYear], from: self))!
    }
}

// Existing placeholder views for other sections
struct CalendarView: View {
    var body: some View {
        Text("Calendar Screen")
            .font(.largeTitle)
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.black.edgesIgnoringSafeArea(.all))
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("Calendar")
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
}
