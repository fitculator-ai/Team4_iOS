//
//  Networking.swift
//  Fitculator
//
//  Created by MadCow on 2025/2/11.
//

import Foundation
import Combine
import Alamofire

protocol UserInfoNetworkingProtocol {
    func fetchUser(key: String) -> AnyPublisher<User, Error>
    func addUser(user: User)
    func deleteUser(key: String)
    func editUser(user: User)
}

protocol TrainingNetworkingProtocol {
    func thisWeekRecord(userId: Int) -> AnyPublisher<[Record], Error>
    func thisWeekMuscleRecordCount(userId: Int) -> AnyPublisher<Int, Error>
    func thisWeekPoints(userId: Int) -> Int
    
    func getExerciseList(type: ExerciseType) -> AnyPublisher<[String], Error>
}

/// url String 값들
/// - thisWeekRecord: 이번주 운동 기록
/// - thisWeekMuscleRecordCount: 이번주 운동 기록 횟수
/// - thisWeekPoint: 이번주 운동 포인트 합
/// - exerciseList: 운동추가 할 때 유산소 / 근력 String 리스트
enum EndPoint: String {
    case thisWeekRecord = "http://13.209.96.25:8000/api/exercise-logs/this-week?user_id="
    case thisWeekMuscleRecordCount = "http://13.209.96.25:8000/api/exercise-logs/strength/count?user_id="
    case thisWeekPoint = "http://13.209.96.25:8000/api/points/weekly?user_id="
    case exerciseList = "http://13.209.96.25:8000/api/exercise/?exercise_type="
}



/// ExerciseType
///  - cardio: 유산소
///  - strength: 근력
//enum ExerciseType: String {
//    case cardio = "유산소"
//    case strength = "근력"
//}

class TrainingNetworking: TrainingNetworkingProtocol {
    func thisWeekRecord(userId: Int) -> AnyPublisher<[Record], Error> {
        let url = EndPoint.thisWeekRecord.rawValue + "\(userId)"
        
        return Future<[Record], Error> { promise in
            AF.request(url)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: [Record].self) { res in
                    switch res.result {
                    case .success(let records):
                        promise(.success(records))
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func thisWeekMuscleRecordCount(userId: Int) -> AnyPublisher<Int, Error> {
        let url = EndPoint.thisWeekPoint.rawValue + "\(userId)"
        
        return Future<Int, Error> { promise in
            AF.request(url)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: [String: Int].self) { res in
                    switch res.result {
                    case .success(let dic):
                        if let count = dic["count"] {
                            promise(.success(count))
                        } else {
                            promise(.success(-1))
                        }
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
    
    func thisWeekPoints(userId: Int) -> Int {
        return 10
    }
    
    func getExerciseList(type: ExerciseType) -> AnyPublisher<[String], Error> {
        let url = EndPoint.exerciseList.rawValue + type.rawValue
        
        return Future<[String], Error> { promise in
            AF.request(url)
                .validate(statusCode: 200..<300)
                .responseDecodable(of: [String: [String]].self) { res in
                    switch res.result {
                    case .success(let dic):
                        if let list = dic["list"] {
                            promise(.success(list))
                        } else {
                            promise(.success([]))
                        }
                    case .failure(let error):
                        promise(.failure(error))
                    }
                }
        }
        .eraseToAnyPublisher()
    }
}

enum Intensity: String, Codable {
    case verLow = "매우 낮음"
    case low = "낮음"
    case normal = "보통"
    case high = "높음"
}

enum Environment2 {
    case development
    case production
    
    var baseURL: String {
        switch self {
        case .development:
            return "http://13.209.96.25:8000"
        case .production:
            return "https://13.209.96.25:8000"
        }
    }
}


enum APIEndPoint{
    case thisWeekRecord(_ userId: Int)
    case fetchExerciesList
   

    var path:String {
        switch self {
        case .thisWeekRecord:
            return "/api/exercies-logs/this-week"
        case .fetchExerciesList:
            return "/api/exercise"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .thisWeekRecord(let userId):
            return [
                URLQueryItem(name: "userId", value: String(userId))
            ]
        case .fetchExerciesList:
            return []
            
        }
    }
    
}
