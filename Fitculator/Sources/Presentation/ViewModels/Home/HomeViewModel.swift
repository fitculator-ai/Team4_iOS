import Foundation
import Combine

class HomeViewModel: ObservableObject {
    @Published var user: User = User()
    @Published var workoutThisWeekHistory: [ThisWeekTraining] = []
    @Published private var isLoading = false
    @Published private var error: NetworkError?
    @Published var selectedDate: Date = Date()

    // DonutChart Data
    @Published var originalTotal: Double = 0.0 // 전체 운동량 저장 변수
    @Published var totalPct: Double = 0.0 // 차트 운동량을 100을 기준으로 저장되는 변수
    @Published var remainingPct: Double = 0.0
    @Published var changedTraningRecordsData: [WorkoutData] = []
    @Published var traningRecords: [[Date: [TrainingRecord]]] = []
    @Published var activeChartData: [WorkoutData] = []
    
    // FatigueChart
    @Published var fatigueValue: Double = 0.0
    
    // WeeklyStrengthReps
    @Published var workoutList: WorkoutList?
    
    private let fetchWorkoutThisWeekHistory: fetchWorkoutThisWeekHistoryUseCase
    private let fetchWorkoutList: fetchWorkoutListUseCase
    private let fetchWorkoutForDate: fetchDataForDateUseCase
    private var cancellables = Set<AnyCancellable>()
    
    init(
        fetchWorkoutThisWeekHistory: fetchWorkoutThisWeekHistoryUseCase,
        fetchWorkoutList: fetchWorkoutListUseCase,
        fetchDataForDate: fetchDataForDateUseCase
    ) {
        self.fetchWorkoutThisWeekHistory = fetchWorkoutThisWeekHistory
        self.fetchWorkoutList = fetchWorkoutList
        self.fetchWorkoutForDate = fetchDataForDate

        fetchWorkoutHistory()
        fetchWorkoutLists()
        updateDonutChartData()
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
    
    func fetchDataForDateHistory(_ selectedDate: Date) {

        let date = formatDateToString(selectedDate)
        print("fetchDataForDateHistory 실행됨, 선택된 날짜: \(date)")
        
        fetchWorkoutForDate.execute(selectedDate: date)
            .sink(receiveCompletion: { [weak self] completion in
                if case let .failure(error) = completion {
                    print("데이터 가져오기 실패: \(error)")
                    self?.error = error as? NetworkError
                }
            }, receiveValue: { [weak self] history in
                DispatchQueue.main.async {
                    print("새롭게 가져온 데이터: \(history)")
                    self?.workoutThisWeekHistory = history
                    self?.updateDonutChartData()
                }
            })
            .store(in: &cancellables)
    }
    
    func fetchWorkoutLists() {
        fetchWorkoutList.execute()
            .sink(receiveCompletion: { completion in
                if case let .failure(error) = completion {
                    print("🏋️운동 리스트 API 에러: \(error)🏋️ \n")
                    self.error = error as? NetworkError
                }
            }, receiveValue: { [weak self] data in
                self?.workoutList = data
                print("🏋️ 받은 운동 리스트: \(data)🏋️ \n")
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
            
            let intensity: Intensity
            switch training.exerciseIntensity {
            case .high:
                intensity = .high
            case .normal:
                intensity = .normal
            case .low:
                intensity = .low
            case .verLow:
                intensity = .verLow
            case .veryHigh:
                intensity = .veryHigh
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
            print("💥💥 record: \(record) 💥💥")
                        
            let day = Calendar.current.startOfDay(for: date)
            grouped[day, default: []].append(record)
            print("💥💥 grouped: \(grouped) 💥💥")
        }
        return [grouped]
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
    
    func updateDonutChartData() {
        self.traningRecords = thisWeekTrainingToDateTrainingRecord(trainings: self.workoutThisWeekHistory)
        print("💥💥traningRecords = \(traningRecords)💥💥 \n")
        let result = changeTrainingDataForChart(traningRecords)
        self.changedTraningRecordsData = result.data
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
    
    /// Date to String (yyyy-MM-dd)
    func formatDateToString(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = TimeZone(identifier: "UTC")
        return formatter.string(from: date)
    }
}
