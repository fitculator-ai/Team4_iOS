//
//  DataSource.swift
//  Fitculator
//
//  Created by MadCow on 2025/2/11.
//

import Foundation
import Combine

class DataSource {
    
    // TODO: - Repository추가 해야함.
    func fetchUsers() -> AnyPublisher<User, Error> {
        return Future { promise in
            let user = User()
            promise(.success(user))
        }
        .eraseToAnyPublisher()
    }
    
}
