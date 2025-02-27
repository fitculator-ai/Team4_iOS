//
//  LoginViewModel.swift
//  Fitculator
//
//  Created by 임재현 on 2/26/25.
//

import SwiftUI

class LoginViewModel: ObservableObject {
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published var userId = ""
    @Published var isValidInput = false
    @Published var errorMessage: String? = nil
    
    private let authUseCase: AuthUseCase
    
    init(authUseCase: AuthUseCase) {
        self.authUseCase = authUseCase
    }
    
    func validateInput() {
        do {
            let validationResult = try authUseCase.validateUserIdWithMessage(userId)
            isValidInput = validationResult.isValid
            errorMessage = validationResult.message
       } catch {
            isValidInput = false
            errorMessage = "유효하지 않은 입력입니다"
        }
    }
    
    @MainActor
    func login() async throws -> Bool {
        guard isValidInput else { return false }
        
        isLoading = true
        defer { isLoading = false }
        
        do {
            return try await authUseCase.login(userId: userId)
        } catch {
            self.error = error
            return false
        }
    }
}
