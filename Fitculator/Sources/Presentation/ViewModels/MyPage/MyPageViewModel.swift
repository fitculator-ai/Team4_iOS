import Foundation

class MyPageViewModel: ObservableObject {
    @Published var weekGraphMockDatas: [Int: [MockData]] = [:]
    @Published var selectedTitle: String? = nil
    @Published var user = UserService.shared.user
    
    init() {
        
    }
}
