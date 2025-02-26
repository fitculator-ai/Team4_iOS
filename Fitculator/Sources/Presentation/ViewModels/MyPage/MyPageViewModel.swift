import Foundation
import Combine

class MyPageViewModel: ObservableObject {
    private let networking = TrainingNetworking()
    private var cancellables = Set<AnyCancellable>()
    var muscleCategory: [String] = [
        "스쿼트",
        "데드리프트",
        "벤치프레스",
        "풀업",
        "랫풀다운",
        "바벨 로우",
        "숄더 프레스",
        "런지",
        "케틀벨 스윙",
        "레그 프레스"
      ]
    
    @Published var thisWeekRecords: [[Record]] = []
    @Published var last25WeeksRecords: [[Record]] = []
    @Published var weeklyMaxPoint: Double = 0
    @Published var selectedTitle: String? = nil
    @Published var weekDateStr: String = ""
    @Published var user = UserService.shared.user
    @Published var selectedWeek: Int? = nil
    @Published var muscleTrainingCount: [Int] = []
    
    init() {
        
    }
    
    func getThisWeekTraining() {
        networking.getThisWeekRecord(userId: 1)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("\(#function) \(#line) >> \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] records in
                guard let self = self else { return }
                
                let calendar = Calendar.current
                let today = Date()
                var result: [[Date: [Record]]] = []
                
                let dic = Dictionary(grouping: records, by: { $0.end_at.components(separatedBy: "T").first! })
                
                if let thisWeekStart = today.startOfWeek(using: calendar) {
                    if let weekStart = calendar.date(byAdding: .weekOfYear, value: 0, to: thisWeekStart) {
                        var weekData: [(Date, [Record])] = []
                        for dayOffset in 0..<7 {
                            if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                                let records = dic[date.dateToString(includeDay: .fullDay2)] ?? [Record(user_id: 1,
                                                                                                       exercise_name: "",
                                                                                                       avg_bpm: 0,
                                                                                                       max_bpm: 0,
                                                                                                       duration: 0,
                                                                                                       end_at: date.dateToString(includeDay: .fullDay2),
                                                                                                       exercise_intensity: .verLow,
                                                                                                       earned_point: 0,
                                                                                                       exercise_note: nil)]
                                weekData.append((date, records))
                            }
                        }
                        weekData.sort { $0.0 < $1.0 }
                        result.append(Dictionary(uniqueKeysWithValues: weekData))
                    }
                }
                
                result = result.reversed()
                
                var datas: [[Record]] = []
                for week in result {
                    datas = week.sorted(by: { $0.key < $1.key }).map { arg in
                        let (_, records) = arg
                        
                        self.getMaxPoint(records: records)
                        
                        return records
                    }
                }
                
                muscleTrainingCount = datas.map {
                    return $0.filter { self.muscleCategory.contains($0.exercise_name) }.count
                }
                thisWeekRecords = datas
                
            }
            .store(in: &cancellables)
    }
    
    func getMaxPoint(records: [Record]) {
        let pointSum = records.map({ $0.earned_point }).reduce(0, +)
        if weeklyMaxPoint < pointSum {
            weeklyMaxPoint = pointSum + 40
        }
    }
    
    func get25WeekTraining() {
        networking.get25WeeksRecords(userId: 1)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    break
                case .failure(let error):
                    print("\(#function) \(#line) >> \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] records in
                guard let self = self else { return }
                let calendar = Calendar.current
                let today = Date()
                var result: [[Date: [Record]]] = []
                
                let dic = Dictionary(grouping: records.map { $0.logs }.flatMap { $0 }, by: { $0.end_at.components(separatedBy: "T").first! })
                for weekOffset in 0..<20 {
                    if let weekStart = calendar.date(byAdding: .weekOfYear, value: -weekOffset, to: today)?.startOfWeek(using: calendar) {
                        var weekData: [(Date, [Record])] = []
                        for dayOffset in 0..<7 {
                            if let date = calendar.date(byAdding: .day, value: dayOffset, to: weekStart) {
                                let records = dic[date.dateToString(includeDay: .fullDay2)] ?? [Record(user_id: 1,
                                                                                                       exercise_name: "",
                                                                                                       avg_bpm: 0,
                                                                                                       max_bpm: 0,
                                                                                                       duration: 0,
                                                                                                       end_at: date.dateToString(includeDay: .fullDay2),
                                                                                                       exercise_intensity: .verLow,
                                                                                                       earned_point: 0,
                                                                                                       exercise_note: nil)]
                                weekData.append((date, records))
                            }
                        }
                        weekData.sort { $0.0 < $1.0 }
                        result.append(Dictionary(uniqueKeysWithValues: weekData))
                    }
                }
                
                result = result.reversed()
                
                var datas: [[Record]] = []
                result.forEach { records in
                    let sortedRecords = records.sorted { $0.key < $1.key }
                    let keys = sortedRecords.map { $0.key }
                    
                    var tempDatas: [Record] = []
                    for (index, week) in sortedRecords.enumerated() {
                        if week.key == keys[index] {
                            tempDatas.append(contentsOf: week.value)
                        }
                    }
                    
                    datas += Array(arrayLiteral: tempDatas)
                }
                
                self.selectedWeek = last25WeeksRecords.count - 1
                last25WeeksRecords = datas
            }
            .store(in: &cancellables)
    }
    
    func setWeekDateStr() {
        weekDateStr = "\(thisWeekRecords.first?.first?.end_at.components(separatedBy: "T").first ?? "") ~ \(thisWeekRecords.last?.last?.end_at.components(separatedBy: "T").first ?? "")"
    }
}
