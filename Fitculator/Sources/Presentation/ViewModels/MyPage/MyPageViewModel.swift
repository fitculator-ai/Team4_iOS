import Foundation

class MyPageViewModel: ObservableObject {
    @Published var lineGraphMockDatas: [(title: String, value: Int)] = []
    @Published var weekGraphMockDatas: [Int: [MockData]] = [:]
    @Published var selectedTitle: String? = nil
    @Published var selectedMockData: MockData? = nil
    
    init() {
        let calendar = Calendar.current
        let today = Date()
        
        lineGraphMockDatas = (0..<7).map { index in
            let dateForamtter = DateFormatter()
            dateForamtter.dateFormat = "MM-dd"
            dateForamtter.locale = Locale(identifier: "ko_KR")
            let str = dateForamtter.string(from: calendar.date(byAdding: .day, value: -index, to: today)!)
            
            return (str, (0...100).randomElement()!)
        }
        
        (0..<4).forEach { idx in
            weekGraphMockDatas[idx] = MockData.dummyData()
        }
    }
}

enum WorkoutType {
    case cardio
    case weight
    case none
}

struct MockData: Identifiable {
    
    // MARK: - MockData
    var id = UUID()
    var name: String
    var pct: Double
    var type: WorkoutType
    
    static func dummyData() -> [MockData] {
        let nameArr: [String] = ["테니스", "HIIT", "러닝", "축구", "배드민턴", "수영", "탁구", "크로스핏", "줄넘기", "야구", "코딩", "Swift", "풋살", "스쿼트", "헬스", "런닝", "경보", "걷기", "베어워크"]
        return [
            MockData(name: nameArr.randomElement()!, pct: Double.random(in: 5...50), type: .weight),
            MockData(name: nameArr.randomElement()!, pct: Double.random(in: 5...50), type: .weight),
            MockData(name: nameArr.randomElement()!, pct: 5, type: .cardio)
        ]
    }
}
