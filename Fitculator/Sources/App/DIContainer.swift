//
//  DIContainer.swift
//  Fitculator
//
//  Created by 임재현 on 2/26/25.
//

import Foundation

final class DIContainer {
    // MARK: - Network Layer
    private let session: URLSession
    private let networkService: NetworkServiceProtocol
    
    // MARK: - Repository Layer
    private let authRepository: AuthRepository
    
    // MARK: - UseCase Layer
    private let authUseCase: AuthUseCase
    
    // MARK: - Initialization
    init(session: URLSession = .shared) {
        // Network Layer
        self.session = session
        self.networkService = NetworkService(session: session)
        
        // Repository Layer
        self.authRepository = AuthRepositoryImplements(networkService: networkService)
        
        // UseCase Layer
        self.authUseCase = AuthUseCase(repository: authRepository)
    }
    
    // MARK: - ViewModel

    func makeLoginViewModel() -> LoginViewModel {
        return LoginViewModel(authUseCase: authUseCase)
    }
}

struct ValidationResult {
    let isValid: Bool
    let message: String?
}

class AuthUseCase {
    private let repository: AuthRepository
    
    init(repository: AuthRepository) {
        self.repository = repository
    }
    
    func login(userId: String) async throws -> Bool {
        return try await repository.login(userId: userId)
    }
    
    func validateUserIdWithMessage(_ userId: String) -> ValidationResult {
        // 1순위: 허용되지 않는 문자 체크
        if userId.contains(" ") {
            return ValidationResult(isValid: false, message: "공백은 사용할 수 없습니다")
        }
        
        let pattern = "^[a-zA-Z0-9가-힣]+$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(userId.startIndex..., in: userId)
        
        if regex?.firstMatch(in: userId, range: range) == nil {
            return ValidationResult(isValid: false, message: "영문자, 숫자, 한글(특수문자,자음/모음 불가)만 사용 가능합니다")
        }
        
        // 2순위: 길이 체크
        if userId.count < 3 {
            return ValidationResult(isValid: false, message: "아이디는 최소 3글자 이상이어야 합니다")
        }
        if userId.count > 16 {
            return ValidationResult(isValid: false, message: "아이디는 16글자까지 가능합니다")
        }
        
        return ValidationResult(isValid: true, message: nil)
    }
    
    func validateUserId(_ userId: String) -> Bool {
        
        guard userId.count >= 2 && userId.count <= 16 else {
            return false
        }
            
        // 2. 공백 체크 (문자열 전체에 공백이 없는지)
        guard !userId.contains(" ") else {
            return false
        }
        
        // 3. 허용된 문자만 포함되어있는지 체크 (영문자, 숫자, 한글)
        let pattern = "^[a-zA-Z0-9가-힣]+$"
        let regex = try? NSRegularExpression(pattern: pattern)
        let range = NSRange(userId.startIndex..., in: userId)
        return regex?.firstMatch(in: userId, range: range) != nil
    }
    
    func logout() async throws {
        try await repository.logout()
    }
}

protocol AuthRepository {
    func login(userId: String) async throws -> Bool
    func logout() async throws
}

class AuthRepositoryImplements: AuthRepository {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func login(userId: String) async throws -> Bool {
        return true
    }
    
    func logout() async throws {
      
    }
}
