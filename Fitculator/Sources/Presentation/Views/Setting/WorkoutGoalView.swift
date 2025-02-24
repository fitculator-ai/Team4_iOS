import SwiftUI

struct WorkoutGoalView: View {
    @Binding var selectedGoal: String
    let goals = ["diet".localized, "muscle_gain".localized, "maintain_weight".localized, "other_goals".localized]
    
    var body: some View {
        List {
            ForEach(goals, id: \.self) { goal in
                HStack {
                    Text(goal)
                    Spacer()
                    if selectedGoal == goal {
                        Image(systemName: "checkmark")
                            .foregroundColor(Color.tabButtonColor)
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    selectedGoal = goal
                }
            }
            .listRowBackground(Color.brightBackgroundColor)
        }
        .scrollContentBackground(.hidden)
        .background(Color.fitculatorBackgroundColor.opacity(1))
        .navigationTitle("fitness_goal".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
}
