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

class fetchWorkoutThisWeekHistoryUseCase {
    private let repository: RepositoryJ
    
    init(repository: RepositoryJ) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<[ThisWeekTraining], Error> {
        return repository.fetchWorkoutThisWeekHistory()
    }
}

class fetchWorkoutListUseCase {
    private let repository: RepositoryJ
    
    init(repository: RepositoryJ) {
        self.repository = repository
    }
    
    func execute() -> AnyPublisher<WorkoutList, Error> {
        return repository.fetchWorkoutList()
    }
}

class fetchDataForDateUseCase {
    private let repository: RepositoryJ
    
    init(repository: RepositoryJ) {
        self.repository = repository
    }
    
    func execute(selectedDate date: String) -> AnyPublisher<[ThisWeekTraining], Error> {
        return repository.fetchDataForDate(date)
    }
}
