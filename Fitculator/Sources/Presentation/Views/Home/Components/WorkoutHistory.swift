import SwiftUI

/// 나의 운동 기록 뷰
struct WorkoutHistory: View {
    
    var traningRecords: [[Date: [TrainingRecord]]] = [[:]]
    
    init(traningRecords: [[Date : [TrainingRecord]]]) {
        self.traningRecords = traningRecords
    }
    
    var body: some View {
        ScrollView{
            VStack(spacing: 10) {
                if let weeklyRecords = traningRecords.first {
                    ForEach(weeklyRecords.keys.sorted(), id: \.self) { date in
                        if let records = weeklyRecords[date] {
                            ForEach(records, id: \.key) { record in
                                if record.trainingName != "" {
                                    WorkoutListCell(
                                        workoutType: record.trainingName,
                                        workoutDate: record.trainingDate
                                            .formatted(),
                                        workoutPoints: Double(
                                            record.gained_point
                                        ),
                                        averageHeartRate: record.avg_bpm,
//                                        calories: 150,
                                        duration: record.duration,
                                        intensity: String(
                                            describing: record.training_intensity
                                        ),
                                        intensityColor: getIntensityColor(for: record.training_intensity),
                                        iconName: getIconData(for: record.trainingName).iconName,
                                        iconBackgroundColor: getIconData(for: record.trainingName).backgroundColor
                                    )
                                }
                            }
                        }
                    }
                }
                    
            }
        }
    }
    
    private func getIconData(for trainingName: String) -> (iconName: String, backgroundColor: Color) {
        let iconData: [String: (String, Color)] = [
            // TODO: - 서버에서 받은 운동리스트와 SFSymbols 어떻게 매치시키지,,?
            // 유산소 운동
            "달리기": ("figure.run", Color.green),
            "사이클": ("bicycle", Color.cyan),
            "수영": ("figure.pool.swim", Color.blue),
            "줄넘기": ("figure.jumprope", Color.orange),
            "등산": ("figure.hiking", Color.green),
            "조깅": ("figure.run", Color.green),
            "걷기": ("figure.walk", Color.green),
            "로잉머신": ("figure.rower", Color.blue),
            "에어로빅": ("heart.fill", Color.pink),
            "스피닝": ("bicycle", Color.gray),
            
            // 근력 운동
            "스쿼트": ("dumbbell", Color.black),
            "데드리프트": ("dumbbell", Color.black),
            "벤치프레스": ("dumbbell", Color.black),
            "풀업": ("dumbbell", Color.black),
            "랫풀다운": ("dumbbell", Color.black),
            "바벨 로우": ("dumbbell", Color.black),
            "숄더 프레스": ("dumbbell", Color.black),
            "런지": ("dumbbell", Color.black),
            "케틀벨 스윙": ("dumbbell", Color.black),
            "레그 프레스": ("dumbbell", Color.black)
        ]
        
        return iconData[trainingName] ?? ("questionmark.circle", Color.gray)
    }
    
    private func getIntensityColor(for intensity: TrainingRecord.Intensity) -> Color {
        switch intensity {
        case .verLow:
            return Color.blue
        case .low:
            return Color.green
        case .normal:
            return Color.orange
        case .high:
            return Color.red
        }
    }
}

// 운동 리스트 Cell
struct WorkoutListCell: View {
    let id = UUID()
    var workoutType: String
    var workoutDate: String
    var workoutPoints: Double
    var averageHeartRate: Int
//    var calories: Int
    var duration: Int
    var intensity: String
    var intensityColor: Color
    var iconName: String
    var iconBackgroundColor: Color
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: iconName)
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .background(iconBackgroundColor.opacity(0.8))
                        .clipShape(Circle())
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(workoutType)
                                .font(.headline)
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(workoutPoints, specifier: "%.1f") pt")
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
//                Spacer()
//                WorkoutDetailView(title: "칼로리", value: "\(calories) kcal")
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
        .background(Color.brightBackgroundColor.opacity(0.6))
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
