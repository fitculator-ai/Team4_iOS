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
    @State var isDisplayHome: Bool = true
    
    var horizontalPadding: CGFloat = 10
    var verticalPadding: CGFloat = 10
    
    var body: some View {
        GeometryReader { geometry in
            let viewHeight = geometry.size.height
            
            // TODO: - "<"누르면 저번주, 한번더 누를시 기간으로 나오게 + 네비게이션 바 추가
            // TODO: - isDisplayHome사용해 하위뷰 분기, CustomNavBar isDisplayHome에 넘겨주기
            NavigationStack {            
                ZStack(alignment: .top) {
                    ScrollView(.vertical, showsIndicators: false) {
                        VStack(spacing: 8) {
                            CustomNavigationBar(
                                isDisplayHome: isDisplayHome,
                            homeBtnAction: {
                            
                            }, calendarBtnAction: { date in
                                viewModel.selectedDate = date
                                viewModel.fetchDataForDateHistory(date)
                            }, notificationBtnAction: {})
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
                    isDisplayHome = isDateInCurrentWeek(viewModel.selectedDate)

                    if isDateInCurrentWeek(viewModel.selectedDate) {
                        viewModel.fetchWorkoutHistory()
                    } else {
                        viewModel
                            .fetchDataForDateHistory(viewModel.selectedDate)
                    }
                    viewModel.updateDonutChartData()
                }
            }
            .onChange(of: viewModel.selectedDate) { newValue, oldValue in
                print("선택된 날짜 변경됨: \(newValue)")
                isDisplayHome = isDateInCurrentWeek(newValue)
                                
                if isDisplayHome {
                    viewModel.fetchWorkoutHistory()
                } else {
                    viewModel.fetchDataForDateHistory(newValue)
                }

                viewModel.updateDonutChartData()
            }
        }
    }
    
    /// 선택한 날짜가 이번 주 월~일 사이인지 확인
    private func isDateInCurrentWeek(_ date: Date) -> Bool {
        let calendar = Calendar.current
        if let weekInterval = calendar.dateInterval(
            of: .weekOfYear,
            for: Date()
        ) {
            let startOfWeek = weekInterval.start
            let endOfWeek = calendar.date(
                byAdding: .day,
                value: 6,
                to: startOfWeek
            )!
            return date >= startOfWeek && date <= endOfWeek
        }
        return false
    }
}

//#Preview {
//    HomeView(viewModel: HomeViewModel(fetchUseCase: UseCase(dataSource: DataSource()), fetchWorkoutThisWeekHistory: <#fetchWorkoutThisWeekHistoryUseCase#>))
//}
