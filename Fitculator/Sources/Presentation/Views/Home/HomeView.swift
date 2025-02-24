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
    let duration: Int
    let type: WorkoutType
}

struct HomeView: View {
    
    @StateObject var viewModel: HomeViewModel
    @State var isDisplayHome: Bool = false
    
    var horizontalPadding: CGFloat = 10
    var verticalPadding: CGFloat = 10
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let viewHeight = geometry.size.height
            
            // TODO: - "<"누르면 저번주, 한번더 누를시 기간으로 나오게 + 네비게이션 바 추가
            // TODO: - isDisplayHome사용해 하위뷰 분기, CustomNavBar isDisplayHome에 넘겨주기
            ZStack(alignment: .top) {
                ScrollView(.vertical) {
                    VStack(spacing: 8) {
                        CustomNavigationBar(isDisplayHome: true, homeBtnAction: {}, calendarBtnAction: {}, notificationBtnAction: {})
                            .zIndex(1)
                            .frame(height: 44)
                        
                        WorkoutDonutChart(user: viewModel.user)
                            .frame(height: viewHeight * 0.4)
                            .padding(.horizontal, horizontalPadding)
                            .padding(.vertical, verticalPadding)
                        
                        FatigueChart(user: viewModel.user)
                            .frame(height: viewHeight * 0.13)
                            .padding(.top, 16)
                            .padding(.horizontal, horizontalPadding)
                            .padding(.vertical, verticalPadding)
                        
                        WeeklyStrengthReps(user: viewModel.user)
                            .frame(height: viewHeight * 0.1)
                            .padding(.horizontal, horizontalPadding)
                            .padding(.vertical, verticalPadding)
                        
                        WorkoutHistory(user: viewModel.user)
                            .padding(.horizontal, horizontalPadding)
                            .padding(.vertical, verticalPadding)
                    }
                }
                .refreshable {
                    viewModel.fetchUser()
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
            }
            .background(Color.fitculatorBackgroundColor)
        }
    }
}

/// [[Date: [TrainingRecord]]] -> [WorkoutData]
func changeTrainingDataForChart(_ records: [[Date: [TrainingRecord]]]) -> (data: [WorkoutData], originalTotal: Double) {
    var dataDict: [String: (points: Double, duration: Int,  type: WorkoutType)] = [:]
    for week in records {
        for (_, dailyRecords) in week {
            for record in dailyRecords {
                let key = "\(record.trainingName)_\(record.gained_point)"
                let workoutType: WorkoutType = (record.trainingName == "근력운동") ? .weight : .cardio

                if var existing = dataDict[key] {
                    existing.points += record.gained_point
                    existing.duration += record.duration
                    dataDict[key] = existing
                } else {
                    dataDict[key] = (record.gained_point, record.duration, workoutType)
                }

            }
        }
    }
    
    let originalTotal = dataDict.values.reduce(0) { $0 + $1.points } // 전체 운동량의 총합
    let total = dataDict.values.reduce(0) { $0 + $1.points } // 비율 조정을 위한 totalPct
    
    // 전체 합이 100을 넘는 경우, 100을 기준으로 비율 조정
    var result: [WorkoutData] = []
    
    if originalTotal > 100 {
        result = dataDict.map { (key, value) -> WorkoutData in
            let adjustedPct = value.points / total * 100

            return WorkoutData(
                name: key,
                pct: adjustedPct,
                actualPoints: value.points,
                duration: value.duration,
                type: value.type
            )
        }
    } else {
        result = dataDict.map { (key, value) -> WorkoutData in
            return WorkoutData(
                name: key,
                pct: value.points,
                actualPoints: value.points,
                duration: value.duration,
                type: value.type
            )
        }
    }
    
    return (result, originalTotal)
}

#Preview {
    HomeView(viewModel: HomeViewModel(fetchUseCase: UseCase(dataSource: DataSource())))
}
