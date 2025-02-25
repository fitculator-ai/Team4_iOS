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
            let viewHeight = geometry.size.height
            
            // TODO: - "<"누르면 저번주, 한번더 누를시 기간으로 나오게 + 네비게이션 바 추가
            // TODO: - isDisplayHome사용해 하위뷰 분기, CustomNavBar isDisplayHome에 넘겨주기
            ZStack(alignment: .top) {
                ScrollView(.vertical, showsIndicators: false) {
                    VStack(spacing: 8) {
                        CustomNavigationBar(isDisplayHome: true, homeBtnAction: {}, calendarBtnAction: {}, notificationBtnAction: {})
                            .zIndex(1)
                            .frame(height: 44)
                        
                        WorkoutDonutChart(
                            originalTotal: viewModel.originalTotal,
                            totalPct: viewModel.totalPct,
                            remainingPct: viewModel.remainingPct,
                            changedTraningRecordsData: viewModel.changedTraningRecordsData,
                            traningRecords: viewModel.traningRecords,
                            activeChartData: viewModel.activeChartData
                        )
                            .frame(height: viewHeight * 0.4)
                            .padding(.horizontal, horizontalPadding)
                            .padding(.vertical, verticalPadding)
                        
                        FatigueChart(
                            fatigueValue: viewModel.fatigueValue,
                            changedTraningRecordsData: viewModel.changedTraningRecordsData,
                            traningRecords: viewModel.traningRecords
                        )
                            .frame(height: viewHeight * 0.13)
                            .padding(.top, 16)
                            .padding(.horizontal, horizontalPadding)
                            .padding(.vertical, verticalPadding)
                        
                        WeeklyStrengthReps(
                            changedTraningRecordsData: viewModel.changedTraningRecordsData,
                            traningRecords: viewModel.traningRecords, workoutList: viewModel.workoutList
                        )
                            .frame(height: viewHeight * 0.1)
                            .padding(.horizontal, horizontalPadding)
                            .padding(.vertical, verticalPadding)
                        
                        WorkoutHistory(traningRecords: viewModel.traningRecords)
                            .padding(.horizontal, horizontalPadding)
                            .padding(.vertical, verticalPadding)
                    }
                }
                .refreshable {
                    viewModel.fetchWorkoutHistory()
                    viewModel.fetchWorkoutLists()
                }
                .padding(.horizontal, horizontalPadding)
                .padding(.vertical, verticalPadding)
            }
            .background(Color.fitculatorBackgroundColor)
            .onAppear {
                viewModel.fetchWorkoutHistory()
                viewModel.updateDonutChartData()
            }
        }
    }
}

//#Preview {
//    HomeView(viewModel: HomeViewModel(fetchUseCase: UseCase(dataSource: DataSource()), fetchWorkoutThisWeekHistory: <#fetchWorkoutThisWeekHistoryUseCase#>))
//}
