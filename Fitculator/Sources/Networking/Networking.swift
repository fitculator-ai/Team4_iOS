//
//  Networking.swift
//  Fitculator
//
//  Created by MadCow on 2025/2/11.
//

import Foundation
import Combine
import Alamofire

protocol TrainingNetworkingProtocol {
    func getThisWeekRecord(userId: Int) -> AnyPublisher<[Record], Error>
    func get25WeeksRecords(userId: Int) -> AnyPublisher<[RecordWithPeriod], Error>
}

class TrainingNetworking: TrainingNetworkingProtocol {
    func getThisWeekRecord(userId: Int) -> AnyPublisher<[Record], Error> {
        do {
            let request = try MyPageAPIEndPoint.getThisWeekRecords(.development, userId).getURLRequest()
            
            return Future<[Record], Error> { promise in
                AF.request(request)
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
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
    
    func get25WeeksRecords(userId: Int) -> AnyPublisher<[RecordWithPeriod], Error> {
        do {
            let request = try MyPageAPIEndPoint.get25WeekRecords(.development, userId).getURLRequest()
            return Future<[RecordWithPeriod], Error> { promise in
                AF.request(request)
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: [RecordWithPeriod].self) { res in
                        switch res.result {
                        case .success(let records):
                            promise(.success(records))
                        case .failure(let error):
                            promise(.failure(error))
                        }
                    }
            }
            .eraseToAnyPublisher()
        } catch {
            return Fail(error: error).eraseToAnyPublisher()
        }
    }
}

struct ThisWeekTraining: Codable, Equatable {
    let userID: Int
    let exerciseName: String
    let avgBPM, maxBPM, duration: Int
    let endAt: String
    let exerciseIntensity: Intensity
    let earnedPoint: Double
    let exerciseNote: String?
    var key: String {
        return "\(endAt)-\(exerciseName)-\(earnedPoint)"
    }
    var endDate: Date? {
        return parseDate(endAt)
    }
    
    enum CodingKeys: String, CodingKey {
        case userID = "user_id"
        case exerciseName = "exercise_name"
        case avgBPM = "avg_bpm"
        case maxBPM = "max_bpm"
        case duration
        case endAt = "end_at"
        case exerciseIntensity = "exercise_intensity"
        case earnedPoint = "earned_point"
        case exerciseNote = "exercise_note"
    }
    func parseDate(_ dateString: String) -> Date? {
        let formats = [
            "yyyy-MM-dd'T'HH:mm:ss.SSSSSS", // 밀리초 포함
            "yyyy-MM-dd'T'HH:mm:ss"         // 초 단위까지
        ]
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(identifier: "UTC")

        for format in formats {
            formatter.dateFormat = format
            if let date = formatter.date(from: dateString) {
                return date
            }
        }
        return nil
    }
}

enum Intensity: String, Codable {
    case verLow = "매우 낮음"
    case low = "낮음"
    case normal = "보통"
    case high = "높음"
    case veryHigh = "매우 높음"
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

enum APIEndPoint {
    case thisWeekRecord(_ userId: Int)
    case fetchExerciesList
    case addExerciseRecord(_ request: AddExerciseRequestDTO)
    case getUserAccountInfo(email: String)
    case getUserDetails(userId: Int)
    case editUserDetails(userId: Int, userInfo: UserProfileInfo)
    case uploadProfileImage(userId: Int)

    var path: String {
        switch self {
        case .thisWeekRecord:
            return "/api/exercies-logs/this-week"
        case .fetchExerciesList:
            return "/api/exercise"
        case .addExerciseRecord:
            return "/api/exercise-logs/"
        case .getUserAccountInfo:
            return "/api/mypage/get-user"
        case .getUserDetails:
            return "/api/mypage/get-user-details"
        case .editUserDetails(let userId, _):
            return "/api/mypage/edit-user/\(userId)"
        case .uploadProfileImage:
            return "/api/mypage/edit-user/profile-image"
        }
    }
    
    var httpMethod: String {
        switch self {
        case .thisWeekRecord, .fetchExerciesList:
            return "GET"
        case .addExerciseRecord:
            return "POST"
        case .getUserAccountInfo:
            return "GET"
        case .getUserDetails:
            return "GET"
        case .editUserDetails:
            return "PUT"
        case .uploadProfileImage:
            return "POST"
        }
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .thisWeekRecord(let userId):
            return [
                URLQueryItem(name: "userId", value: String(userId))
            ]
        case .fetchExerciesList,.addExerciseRecord:
            return []
        case .getUserAccountInfo(let email):
            return [URLQueryItem(name: "email", value: email)]
        case .getUserDetails(let userId):
            return [URLQueryItem(name: "user_id", value: String(userId))
            ]
        case .editUserDetails:
            return []
        case .uploadProfileImage(let userId):
            return [URLQueryItem(name: "user_id", value: String(userId))
            ]
        }
    }
    
    var headers: [String: String] {
        return [
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]
    }
}

enum MyPageAPIEndPoint {
    case getThisWeekRecords(_ environment: Environment2, _ userId: Int)
    case get25WeekRecords(_ environment: Environment2, _ userId: Int)
    
    var path: String {
        switch self {
        case .getThisWeekRecords(let environment, _):
            return "\(environment.baseURL)/api/exercise-logs/this-week"
        case .get25WeekRecords(let environment, _):
            return "\(environment.baseURL)/api/mypage/get-exercise-logs/25weeks"
        }
    }
    
    var method: HTTPMethod {
        return .get
    }
    
    var headers: HTTPHeaders {
        return ["Content-Type": "application/json"]
    }
    
    var queryItems: [URLQueryItem] {
        switch self {
        case .getThisWeekRecords(_, let userId),
             .get25WeekRecords(_, let userId):
            return [URLQueryItem(name: "user_id", value: "\(userId)")]
        }
    }
    
    func getURLRequest() throws -> URLRequest {
        guard var urlComponents = URLComponents(string: self.path) else {
            throw URLError(.badURL)
        }
        
        urlComponents.queryItems = queryItems
        
        guard let url = urlComponents.url else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.method = self.method
        request.headers = self.headers

        return request
    }
}

// MARK: - 운동리스트 API 모델
struct WorkoutList: Decodable {
    let cardio: [WorkoutListItem]
    let strength: [WorkoutListItem]
    
    private enum CodingKeys: String, CodingKey {
        case cardio = "유산소"
        case strength = "근력"
    }
}

struct WorkoutListItem: Decodable, Identifiable {
    let id: Int
    let name: String

}
