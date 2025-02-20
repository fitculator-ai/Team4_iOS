import Foundation

class MyPageViewModel: ObservableObject {
    @Published var selectedTitle: String? = nil
    @Published var user = UserService.shared.user
    @Published var weeklyTrainingData: [[TrainingRecord]] = []
    @Published var weeklyMaxPoint: Double = 0
    @Published var trainingFatigueDatas: [[TrainingRecord]] = []
    @Published var selectedWeek: Int? = nil
    @Published var filteredTrainingCount: [Int] = []
    @Published var weekDateStr: String = ""

    func fetchWeeklyData(period: RecordPeriod) {
        let trainingRecords = user.getTrainingRecords(for: period)
        var datas: [[TrainingRecord]] = []
        for week in trainingRecords {
            datas = week.sorted(by: { $0.key < $1.key }).map { arg in
                let (_, records) = arg
                
                getMaxPoint(records: records)
                
                return records
            }
        }
        
        filteredTrainingCount = datas.map {
            return $0.filter { $0.trainingName == "근력운동" }.count
        }
        weeklyTrainingData = datas
        setWeekDateStr()
    }
    
    func fetchAllData(period: RecordPeriod) {
        let trainingRecords = user.getTrainingRecords(for: period)
        var datas: [[TrainingRecord]] = []
        trainingRecords.forEach { records in
            let sortedRecords = records.sorted { $0.key < $1.key }
            let keys = sortedRecords.map { $0.key }
            
            var tempDatas: [TrainingRecord] = []
            for (index, week) in sortedRecords.enumerated() {
                if week.key == keys[index] {
                    tempDatas.append(contentsOf: week.value)
                }
            }
            
            datas += Array(arrayLiteral: tempDatas)
        }
        
        self.selectedWeek = trainingRecords.count - 1
        self.trainingFatigueDatas = datas
    }
    
    func getMaxPoint(records: [TrainingRecord]) {
        let pointSum = records.map({ $0.gained_point }).reduce(0, +)
        if weeklyMaxPoint < pointSum {
            weeklyMaxPoint = pointSum + 40
        }
    }
    
    func setWeekDateStr() {
        weekDateStr = "\(weeklyTrainingData.first?.first?.trainingDate.dateToString(includeDay: .fullDay) ?? "") ~ \(weeklyTrainingData.last?.last?.trainingDate.dateToString(includeDay: .fullDay) ?? "")"
    }
    
    init() {}
}
