import SwiftUI
import Alamofire
import Combine

class AccountInfoViewModel: ObservableObject {
    @Published var user: UserAccountInfo?
    @Published var error: Error?
    private var cancellables = Set<AnyCancellable>()
    private let userAccount: UserAccountUseCase
    
    init(userAccountUseCase: UserAccountUseCase) {
        self.userAccount = userAccountUseCase
    }
    
    func getUserAccountInfo(email: String) {
        userAccount.execute(email: email)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.error = error
                    print("Error fetching user info: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { userInfo in
                self.user = userInfo
            })
            .store(in: &cancellables)
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
