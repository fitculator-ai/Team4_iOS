import SwiftUI
import Alamofire
import Combine

// 엔티티에 추가 및 User 확인 후 변경 필요할 듯..
//mypage get user하면 이메일 넣고 이 정보가 받아와짐
struct UserAccountInfo: Codable {
    let name: String
    let token: String
    let email: String // 이메일 넣어서 이메일 받아와야 함
}

// 사용자 프로필 정보(성별이 빠짐)
// 로그인은 이메일로 하고 토큰 발급됨
// edit할 때 userid 넘겨야 되고 아래 정보 수정가능함
struct UserProfileInfo: Codable {
    let userNickname: String
    let exerciseIssue: String
    let exerciseGoal: String
    let restingBpm: Int
    let height: Int
    let birth: String
    let device: String
    let profileImage: String
}

class UserInfoAPI: ObservableObject {
    @Published var user: UserAccountInfo?
    @Published var userProfile: UserProfileInfo?
    private var cancellables = Set<AnyCancellable>()
    
    // 각 함수 UseCase에 추가
    func getUserAccountInfo(email: String) {
        let url = "http://13.209.96.25:8000/api/mypage/get-user"
        let parameters: Parameters = ["email": email]
        
        AF.request(url, method: .get, parameters: parameters)
            .publishDecodable(type: UserAccountInfo.self)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    print("Error: \(error.localizedDescription)")
                case .finished:
                    break
                }
            }, receiveValue: { [weak self] response in
                //print(response)
                if let user = response.value {
                    self?.user = user
                }
            })
            .store(in: &cancellables)
    }
}
