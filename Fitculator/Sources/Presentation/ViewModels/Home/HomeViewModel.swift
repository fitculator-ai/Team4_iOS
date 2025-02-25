import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var user: User = User()
    @Published var workoutThisWeekHistory: [ThisWeekTraining] = []
    @Published private var isLoading = false
    @Published private var error: NetworkError?

    // DonutChart Data
    @Published var originalTotal: Double = 0.0 // 전체 운동량 저장 변수
    @Published var totalPct: Double = 0.0 // 차트 운동량을 100을 기준으로 저장되는 변수
    @Published var remainingPct: Double = 0.0
    @Published var changedTraningRecordsData: [WorkoutData] = []
    @Published var traningRecords: [[Date: [TrainingRecord]]] = []
    @Published var activeChartData: [WorkoutData] = []
    
    // FatigueChart
    @Published var fatigueValue: Double = 0.0
    
    private let fetchUseCase: UseCase
    private let fetchWorkoutThisWeekHistory: fetchWorkoutThisWeekHistoryUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(fetchUseCase: UseCase, fetchWorkoutThisWeekHistory: fetchWorkoutThisWeekHistoryUseCase) {
        self.fetchUseCase = fetchUseCase
        self.fetchWorkoutThisWeekHistory = fetchWorkoutThisWeekHistory

        fetchUser()
        fetchWorkoutHistory()
        updateDonutChartData()
    }
    
    func fetchUser() {
        fetchUseCase.execute()
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.error = error as? NetworkError
                }
            }, receiveValue: { [weak self] user in
                self?.user = user
            })
            .store(in: &cancellables)
    }
    
    func fetchWorkoutHistory() {
        fetchWorkoutThisWeekHistory.execute()
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    self?.error = error as? NetworkError
                }
            }, receiveValue: { [weak self] history in
                self?.workoutThisWeekHistory = history
                self?.updateDonutChartData()
            })
            .store(in: &cancellables)
    }
    
    func thisWeekTrainingToDateTrainingRecord(trainings: [ThisWeekTraining]) -> [[Date: [TrainingRecord]]] {
        var grouped: [Date: [TrainingRecord]] = [:]

        trainings.forEach { training in
            
            guard let date = training.endDate,
                  let training_detail = training.exerciseNote
            else {
                print("💥💥 날짜 파싱 실패: \(training.endAt) 💥💥")
                return
            }
            
            let intensity: TrainingRecord.Intensity
            switch training.exerciseIntensity {
            case .high:
                intensity = .high
            case .normal:
                intensity = .normal
            case .low:
                intensity = .low
            case .verLow:
                intensity = .verLow
            }
            
            let record = TrainingRecord(
                trainingDate: date,
                trainingName: training.exerciseName,
                avg_bpm: training.avgBPM,
                duration: training.duration,
                end_at: date,
                training_intensity: intensity,
                gained_point: training.earnedPoint,
                training_detail: training_detail,
                max_bpm: training.maxBPM
            )
            
            print("💥💥 record= \(record) 💥💥\n")
            
            let day = Calendar.current.startOfDay(for: date)
            grouped[day, default: []].append(record)
        }
        print("💥💥 grouped= \([grouped]) 💥💥\n")
        return [grouped]
    }
    
    func updateDonutChartData() {
        self.traningRecords = thisWeekTrainingToDateTrainingRecord(trainings: self.workoutThisWeekHistory)
        print("💥💥traningRecords = \(traningRecords)💥💥 \n")
        let result = changeTrainingDataForChart(traningRecords)
        print("💥💥result = \(result)💥💥 \n")
        self.changedTraningRecordsData = result.data
        print("💥💥changedTraningRecordsData = \(changedTraningRecordsData)💥💥 \n")
        self.originalTotal = result.originalTotal
        self.totalPct = changedTraningRecordsData.reduce(0) { $0 + $1.pct }
        self.remainingPct = max(100 - totalPct, 0)
        self.activeChartData = totalPct < 100
        ? changedTraningRecordsData + [WorkoutData(
            name: "남은 운동량_",
            pct: remainingPct,
            actualPoints: remainingPct,
            duration: 0,
            type: .none
        )]
        : changedTraningRecordsData
        self.fatigueValue = originalTotal / 100
    }
}
