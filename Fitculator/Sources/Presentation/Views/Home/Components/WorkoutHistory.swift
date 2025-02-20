import SwiftUI

/// 나의 운동 기록 뷰
struct WorkoutHistory: View {
    
    let workouts = [
        WorkoutListCell(
            workoutType: "달리기",
            workoutDate: "11.18 오후 6:41",
            workoutPoints: 12,
            averageHeartRate: 90,
            calories: 90,
            duration: 30,
            intensity: "매우낮음",
            intensityColor: Color.yellow,
            iconName: "figure.run"
        ),
        WorkoutListCell(
            workoutType: "자전거2",
            workoutDate: "11.20 오전 7:30",
            workoutPoints: 18,
            averageHeartRate: 105,
            calories: 150,
            duration: 40,
            intensity: "보통",
            intensityColor: Color.green,
            iconName: "bicycle"
        ),
        WorkoutListCell(
            workoutType: "자전거",
            workoutDate: "11.20 오전 7:30",
            workoutPoints: 18,
            averageHeartRate: 105,
            calories: 150,
            duration: 40,
            intensity: "보통",
            intensityColor: Color.green,
            iconName: "bicycle"
        )
    ]
    
    var body: some View {
        ScrollView{
            VStack(spacing: 10) {
                ForEach(workouts, id: \.workoutType) { workout in
                    workout
                }
            }
        }
    }
}

// 운동 리스트 Cell
struct WorkoutListCell: View {
    var workoutType: String
    var workoutDate: String
    var workoutPoints: Int
    var averageHeartRate: Int
    var calories: Int
    var duration: Int
    var intensity: String
    var intensityColor: Color
    var iconName: String
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: iconName)
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .background(Color.purple.opacity(0.8))
                        .clipShape(Circle())
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(workoutType)
                                .font(.headline)
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(workoutPoints) pt")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Text(workoutDate)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Divider()
                .background(Color.gray.opacity(0.5))
            
            HStack {
                WorkoutDetailView(
                    title: "평균 심박",
                    value: "\(averageHeartRate) bpm"
                )
                Spacer()
                WorkoutDetailView(title: "칼로리", value: "\(calories) kcal")
                Spacer()
                WorkoutDetailView(title: "시간", value: "\(duration) min")
                Spacer()
                WorkoutDetailView(
                    title: "강도",
                    value: intensity,
                    textColor: intensityColor
                )
            }
            .padding(.top, 5)
        }
        .padding()
        .background(Color.purple.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

/// 운동 리스트 Cell 서브 뷰
struct WorkoutDetailView: View {
    var title: String
    var value: String
    var textColor: Color = .white
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                
            Text(value)
                .font(.subheadline)
                .bold()
                .foregroundColor(textColor)
        }
    }
}

//#Preview {
//    WorkoutListCell(
//        workoutType: "달리기",
//        workoutDate: "11.18 오후 6:41",
//        workoutPoints: 12,
//        averageHeartRate: 90,
//        calories: 90,
//        duration: 30,
//        intensity: "매우낮음",
//        intensityColor: Color.yellow,
//        iconName: "figure.run"
//    )
//}
