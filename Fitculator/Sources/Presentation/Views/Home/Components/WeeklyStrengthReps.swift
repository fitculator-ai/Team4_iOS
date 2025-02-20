import SwiftUI
import Charts

/// 근력 횟수 차트
struct WeeklyStrengthReps: View {
    
    @State var user: User
    
    var traningRecords: [[Date: [TrainingRecord]]]
    // traningRecords 데이터 변환
    var changedTraningRecordsData: [WorkoutData]
    var weightCount: Int
    
    init(user: User) {
        self.user = user
        self.traningRecords = user.getTrainingRecords(for: .oneWeek)
        let result = changeTrainingDataForChart(traningRecords)
        self.changedTraningRecordsData = result.data
        self.weightCount = changedTraningRecordsData.filter { $0.type == WorkoutType.weight }.count
        
    }
    
    var body: some View {
       
        ZStack {
            HStack {
                Text("근력")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .offset(y: -40)
                Spacer()
                Text("\(weightCount) / 2")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .offset(y: -40)
            }
            StrengthRepsBackgroundLine()
                .trim(from: 0, to: 1)
                .stroke(
                    Color.fatigueBackgroundColor,
                    style: StrokeStyle(
                        lineWidth: 40,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .padding(.leading, 20)
                .padding(.trailing, 20)
            HStack{
                WorkoutCountLine()
                    .trim(from: 0, to: 1)
                    .stroke(
                        Color.gray,
                        style: StrokeStyle(
                            lineWidth: 25,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                WorkoutCountLine()
                    .trim(from: 0, to: 1)
                    .stroke(
                        Color.gray,
                        style: StrokeStyle(
                            lineWidth: 25,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                
            }
            HStack {
                ForEach(0..<2, id: \.self) { index in
                    WorkoutCountLine()
                        .trim(from: 0, to: 1)
                        .stroke(
                            index < weightCount ? Color.blue : Color.gray,
                            style: StrokeStyle(
                                lineWidth: 25,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                        .padding(.leading, index == 0 ? 20: 10)
                        .padding(.trailing, index == 0 ? 10 : 20)
                }
            }
        }
    }
}

/// 근력 횟수 백그라운드 선
struct StrengthRepsBackgroundLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}
