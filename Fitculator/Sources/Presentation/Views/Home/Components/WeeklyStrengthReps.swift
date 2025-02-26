import SwiftUI
import Charts

/// 근력 횟수 차트
struct WeeklyStrengthReps: View {
    
    @State var weightCount: Int = 0
    
    var changedTraningRecordsData: [WorkoutData] = []
    var traningRecords: [[Date: [TrainingRecord]]] = []
    var workoutList: WorkoutList?
    
    init(
        changedTraningRecordsData: [WorkoutData],
        traningRecords: [[Date : [TrainingRecord]]],
        workoutList: WorkoutList?
    ) {
        self.changedTraningRecordsData = changedTraningRecordsData
        self.traningRecords = traningRecords
        self.workoutList = workoutList
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
        .onAppear {
            updateWeeklyStreengthReps()
            weightCount = calculateWeightCount()
        }
        .onChange(of: traningRecords) { oldValue, newValue in
            updateWeeklyStreengthReps()
            weightCount = calculateWeightCount()
        }
    }
    
    func updateWeeklyStreengthReps() {
        weightCount = calculateWeightCount()
    }
    
    // TODO: - 근력운동 횟수
    func calculateWeightCount() -> Int {
        guard let weightExercises = workoutList?.strength else { return 0 }
            
        var calculatedCount = 0
        for record in changedTraningRecordsData {
            let components = record.name.split(separator: "_")
            guard let exerciseName = components.first.map({ String($0) }) else {
                continue
            }
                
            if record.duration >= 30 && weightExercises
                .contains(where: { $0.name == exerciseName }) {
                calculatedCount += 1
            }
        }
        return calculatedCount
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
