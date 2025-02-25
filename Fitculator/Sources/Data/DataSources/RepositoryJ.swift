//
//  RepositoryJ.swift
//  Fitculator
//
//  Created by 정종원 on 2/25/25.
//

import Foundation

import Combine

protocol RepositoryJ {
    func fetchWorkoutThisWeekHistory() -> AnyPublisher<[ThisWeekTraining], Error>
    
    func fetchWorkoutList() -> AnyPublisher<WorkoutList, Error>
}

class RepositoryJImpl: RepositoryJ {
    
    private let dataSource: DataSource
    
    init(dataSource: DataSource) {
        self.dataSource = dataSource
    }
    
    func fetchWorkoutThisWeekHistory() -> AnyPublisher<[ThisWeekTraining], any Error> {
        return dataSource.fetchWorkoutThisWeekHistory(userID: 1)
    }
    
    func fetchWorkoutList() -> AnyPublisher<WorkoutList, Error> {
        return dataSource.fetchWorkoutList()
    }
}
