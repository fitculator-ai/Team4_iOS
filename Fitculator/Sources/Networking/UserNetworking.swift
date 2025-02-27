//
//  UserNetworking.swift
//  Fitculator
//
//  Created by MadCow on 2025/2/27.
//

import Foundation
import Combine
import Alamofire

protocol UserInfoNetworkingProtocol {
    func fetchUser(userId: Int) -> AnyPublisher<UserProfileInfo, Error>
//    func addUser(user: User)
//    func deleteUser(key: String)
//    func editUser(user: User)
}

class UserNetworking: UserInfoNetworkingProtocol {
    func fetchUser(userId: Int) -> AnyPublisher<UserProfileInfo, Error> {
        do {
            let request = try UserAPIEndPoint.fetchUser(.development, userId).getURLRequest()
            
            return Future<UserProfileInfo, Error> { promise in
                AF.request(request)
                    .validate(statusCode: 200..<300)
                    .responseDecodable(of: UserProfileInfo.self) { res in
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

enum UserAPIEndPoint {
    case fetchUser(_ environment: Environment2, _ id: Int)
    
    var path: String {
        switch self {
        case .fetchUser(let environment, _):
            return "\(environment.baseURL)/api/mypage/get-user-details"
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
        case .fetchUser(_, let id):
            return [URLQueryItem(name: "user_id", value: "\(id)")]
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
