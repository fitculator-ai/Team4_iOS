//
//  UserService.swift
//  Fitculator
//
//  Created by MadCow on 2025/2/18.
//

import Foundation
import Combine

class UserService: ObservableObject {
    static let shared = UserService()
    private let networkService = UserNetworking()
    private var cancellable = Set<AnyCancellable>()
    
    var user: UserProfileInfo
    
    private init() {
        self.user = UserProfileInfo(userNickname: "", exerciseIssue: "", exerciseGoal: "", restingBpm: 0, height: 0, birth: "", device: "", profileImage: "", gender: "")
        
        networkService.fetchUser(userId: 1)
            .receive(on: DispatchQueue.main)
            .sink { completion in
                switch completion {
                case .finished:
                    print("로그인 완료!")
                case .failure(let error):
                    print("로그인 실패! > \(error.localizedDescription)")
                }
            } receiveValue: { [weak self] user in
                guard let self = self else { return }
                print(user)
                self.user = user
            }
            .store(in: &cancellable)
    }
}
