import SwiftUI
import Alamofire
import Combine

class AccountInfoViewModel: ObservableObject {
    @Published var user: UserAccountInfo?
    private var cancellables = Set<AnyCancellable>()
    private let userInfoAPI = UserInfoAPI()

    init() {
        userInfoAPI.$user
            .assign(to: &$user)
    }

    // 사용자 정보 가져오기 -> 현재 이메일을 받아오기 위해 파라미터로 이메일을 넣어야하는 이상한 상황,,
    func getUserEmail(email: String) {
        userInfoAPI.getUserAccountInfo(email: email)
    }
    
    // 로그아웃
    func userLogout() {
        print("User logged out")
    }

    // 회원 탈퇴
    func userWithdraw() {
        print("User withdrawal initiated")
    }
}
