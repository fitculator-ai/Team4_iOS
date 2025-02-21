import SwiftUI
import Charts

enum WorkoutType {
    case cardio
    case weight
    case none
}

struct WorkoutData: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let pct: Double // 보정된 운동포인트 값
    let actualPoints: Double // 실제 운동 포인트 값
    let type: WorkoutType
}

struct HomeView: View {
    
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let viewHeight = geometry.size.height
            VStack {
                ScrollView(.vertical) {
                    VStack(spacing: 16) {
                        WorkoutDonutChart(user: viewModel.user)
                            .frame(height: viewHeight * 0.4)
                        
                        FatigueChart(user: viewModel.user)
                            .frame(width: viewWidth - 20, height: viewHeight * 0.13)
                            .padding(.top, 16)
                        
                        WeeklyStrengthReps(user: viewModel.user)
                            .frame(width: viewWidth - 20, height: viewHeight * 0.1)
                        
                        WorkoutHistory()
                            .frame(width: viewWidth - 20)
                    }
                    .padding(.horizontal, 10)
                    .padding(.vertical, 10)
                }
            }
            .background(Color.fitculatorBackgroundColor)
        }
    }
}

/// [[Date: [TrainingRecord]]] -> [WorkoutData]
func changeTrainingDataForChart(_ records: [[Date: [TrainingRecord]]]) -> (data: [WorkoutData], originalTotal: Double) {
    var dataDict: [String: Double] = [:]
    
    for week in records {
        for (_, dailyRecords) in week {
            for record in dailyRecords {
                let key = "\(record.trainingName)_\(record.gained_point)"
                dataDict[key, default: 0] += record.gained_point
            }
        }
    }
    
    let originalTotal = dataDict.values.reduce(0, +) // 전체 운동량의 총합
    let total = dataDict.values.reduce(0, +) // 비율 조정을 위한 totalPct
    
    // 전체 합이 100을 넘는 경우, 100을 기준으로 비율 조정
    var result: [WorkoutData] = []
    if originalTotal > 100 {
        result = dataDict.map { (key, value) -> WorkoutData in
            let adjustedPct = value / total * 100  // 전체 합이 100을 초과하면 비율을 조정
            return WorkoutData(name: key, pct: adjustedPct, actualPoints: value, type: .weight)
        }
    } else {
        result = dataDict.map { (key, value) -> WorkoutData in
            return WorkoutData(
                name: key,
                pct: value, actualPoints: value,
                type: .weight
            )
        }
    }
    
    return (result, originalTotal)
}

#Preview {
    HomeView(viewModel: HomeViewModel(fetchUseCase: UseCase(dataSource: DataSource())))
}
