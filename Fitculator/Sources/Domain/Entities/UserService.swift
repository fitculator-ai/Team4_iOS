//
//  UserService.swift
//  Fitculator
//
//  Created by MadCow on 2025/2/18.
//

import Foundation

class UserService {
    static let shared = UserService()
    
    let user = User()
    
    private init() {}
}
