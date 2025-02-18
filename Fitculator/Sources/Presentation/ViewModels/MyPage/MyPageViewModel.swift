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
