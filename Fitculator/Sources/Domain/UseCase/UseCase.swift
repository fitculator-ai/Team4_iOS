//
//  UseCase.swift
//  Fitculator
//
//  Created by MadCow on 2025/2/11.
//

import Foundation
import Combine

class UseCase {
    private let dataSource: DataSource
    
    init(dataSource: DataSource) {
        self.dataSource = dataSource
    }

    func execute() -> AnyPublisher<User, Error> {
        return dataSource.fetchUsers()
    }
}
