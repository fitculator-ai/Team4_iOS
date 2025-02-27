//
//  AuthState.swift
//  Fitculator
//
//  Created by 임재현 on 2/26/25.
//

import Combine

class AuthState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userId: String = ""
    
    func logout() {
        isLoggedIn = false
    }
}
