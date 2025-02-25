//
//  DataSource.swift
//  Fitculator
//
//  Created by MadCow on 2025/2/11.
//

import Foundation
import Combine
import Alamofire

class DataSource {
    // TODO: - Repository추가 해야함.
    func fetchUsers() -> AnyPublisher<User, Error> {
        return Future { promise in
            let user = User()
            promise(.success(user))
        }
        .eraseToAnyPublisher()
    }
    
    func fetchWorkoutThisWeekHistory(userID: Int) -> AnyPublisher<[ThisWeekTraining], Error> {
        let urlString = EndpointJ.perWeek + "\(userID)"
        guard URL(string: urlString) != nil else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return AF.request(urlString)
            .publishDecodable(type: [ThisWeekTraining].self)
            .value()
            .receive(on: DispatchQueue.main)
            .mapError { (afterError: AFError)  in
                return afterError as Error
            }
            .eraseToAnyPublisher()
    }
    
    func fetchWorkoutList() -> AnyPublisher<WorkoutList, Error> {
        let urlString = EndpointJ.workoutList
        guard URL(string: urlString) != nil else {
            return Fail(error: URLError(.badURL))
                .eraseToAnyPublisher()
        }
        
        return AF.request(urlString)
            .publishDecodable(type: WorkoutList.self)
            .value()
            .receive(on: DispatchQueue.main)
            .mapError { (afterError: AFError)  in
                return afterError as Error
            }
            .eraseToAnyPublisher()
    }
}
