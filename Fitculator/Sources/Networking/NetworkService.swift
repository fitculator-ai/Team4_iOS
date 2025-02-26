//
//  NetworkService.swift
//  Fitculator
//
//  Created by 임재현 on 2/24/25.
//

import Foundation
import Combine
import Alamofire

protocol NetworkServiceProtocol {
    func request<T:Decodable>(_ endPoint:APIEndPoint,
                              environment:Environment2) -> AnyPublisher<T, NetworkError>
    func request<T: Decodable, U: Encodable>(_ endPoint: APIEndPoint,
                                             environment: Environment2,
                                             method: HTTPMethod, body: U?) -> AnyPublisher<T, NetworkError>
    func uploadMultipartFormData<T: Decodable>(_ endPoint: APIEndPoint,
                                               environment: Environment2,
                                               imageData: Data) -> AnyPublisher<T, NetworkError>
}

struct NetworkService: NetworkServiceProtocol {
    private let session: URLSession
    private let logger: NetworkLogging
    private let timeoutInterval: TimeInterval
    
    init(session: URLSession = .shared,
         logger: NetworkLogging = DefaultNetworkLogging(),
         timeoutInterval: TimeInterval = 30) {
        self.session = session
        self.logger = logger
        self.timeoutInterval = timeoutInterval
    }

    func request<T: Decodable>(_ endpoint: APIEndPoint,
                             environment: Environment2) -> AnyPublisher<T, NetworkError> {

        
        guard var components = URLComponents(string: environment.baseURL + endpoint.path) else {
            return Fail(error: NetworkError.invalidURL("Invalid base URL or path"))
                .eraseToAnyPublisher()
        }
      
        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }
            
        guard let url = components.url else {
            return Fail(error: NetworkError
                .invalidURL("Could not construct URL from components"))
                .eraseToAnyPublisher()
        }
            
        var request = URLRequest(url: url)
        request.timeoutInterval = timeoutInterval
        

        request.httpMethod = endpoint.httpMethod
        

        for (key, value) in endpoint.headers {
            request.addValue(value, forHTTPHeaderField: key)
        }
        

        if case .addExerciseRecord(let requestDTO) = endpoint {
            do {
                let encoder = JSONEncoder()
                request.httpBody = try encoder.encode(requestDTO)
            } catch {
                return Fail(error: NetworkError.decodingError(error))
                    .eraseToAnyPublisher()
            }
        }
        
            logger.log(request: request)
        
        
        
        return session.dataTaskPublisher(for: request)
            .mapError { NetworkError.networkError($0) }
            .flatMap { data, response -> AnyPublisher<T, NetworkError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
                }
                logger.log(response: httpResponse, data: data)
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    
                    let message = String(data: data, encoding: .utf8)
                    return Fail(error: NetworkError.from(
                        statusCode: httpResponse.statusCode,
                        message: message
                    ))
                    .eraseToAnyPublisher()
                }
                
                return Just(data)
                    .decode(type: T.self, decoder: JSONDecoder())
                    .mapError { NetworkError.decodingError($0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func request<T: Decodable, U: Encodable>(_ endpoint: APIEndPoint,
                                             environment: Environment2,
                                             method: HTTPMethod,
                                             body: U?) -> AnyPublisher<T, NetworkError> {
        
        guard var components = URLComponents(string: environment.baseURL + endpoint.path) else {
            return Fail(error: NetworkError.invalidURL("Invalid base URL or path"))
                .eraseToAnyPublisher()
        }
        
        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }
        
        guard let url = components.url else {
            return Fail(error: NetworkError.invalidURL("Could not construct URL from components"))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = timeoutInterval
        request.addValue("application/json", forHTTPHeaderField: "accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpMethod = method.rawValue
        
        if let body = body, method != .get {
            do {
                request.httpBody = try JSONEncoder().encode(body)
            } catch {
                return Fail(error: NetworkError.encodingError(error))
                    .eraseToAnyPublisher()
            }
        }
        
        logger.log(request: request)
        
        return session.dataTaskPublisher(for: request)
            .mapError { NetworkError.networkError($0) }
            .flatMap { data, response -> AnyPublisher<T, NetworkError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
                }
                logger.log(response: httpResponse, data: data)
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let message = String(data: data, encoding: .utf8)
                    return Fail(error: NetworkError.from(
                        statusCode: httpResponse.statusCode,
                        message: message
                    ))
                    .eraseToAnyPublisher()
                }
                
                return Just(data)
                    .decode(type: T.self, decoder: JSONDecoder())
                    .mapError { NetworkError.decodingError($0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    func uploadMultipartFormData<T: Decodable>(_ endpoint: APIEndPoint,
                                               environment: Environment2,
                                               imageData: Data) -> AnyPublisher<T, NetworkError> {
        guard var components = URLComponents(string: environment.baseURL + endpoint.path) else {
            return Fail(error: NetworkError.invalidURL("Invalid base URL or path"))
                .eraseToAnyPublisher()
        }
        
        if !endpoint.queryItems.isEmpty {
            components.queryItems = endpoint.queryItems
        }
        
        guard let url = components.url else {
            return Fail(error: NetworkError.invalidURL("Could not construct URL from components"))
                .eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.timeoutInterval = timeoutInterval
        request.httpMethod = "POST"
        
        let boundary = "Boundary-\(UUID().uuidString)"
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
        
        var body = Data()
        
        body.append("\r\n--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"image.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(imageData)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        
        request.httpBody = body
        
        logger.log(request: request)
        
        return session.dataTaskPublisher(for: request)
            .mapError { NetworkError.networkError($0) }
            .flatMap { data, response -> AnyPublisher<T, NetworkError> in
                guard let httpResponse = response as? HTTPURLResponse else {
                    return Fail(error: NetworkError.invalidResponse).eraseToAnyPublisher()
                }
                logger.log(response: httpResponse, data: data)
                
                guard (200...299).contains(httpResponse.statusCode) else {
                    let message = String(data: data, encoding: .utf8)
                    return Fail(error: NetworkError.from(
                        statusCode: httpResponse.statusCode,
                        message: message
                    ))
                    .eraseToAnyPublisher()
                }
                
                return Just(data)
                    .decode(type: T.self, decoder: JSONDecoder())
                    .mapError { NetworkError.decodingError($0) }
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
}




protocol NetworkLogging {
    func log(request: URLRequest)
    func log(response: HTTPURLResponse, data: Data)
}

struct DefaultNetworkLogging: NetworkLogging {
    func log(request: URLRequest) {
        #if DEBUG
        print("Request URL:", request.url?.absoluteString ?? "")
        print("Request Headers:", request.allHTTPHeaderFields ?? [:])
        if let token = request.value(forHTTPHeaderField: "Authorization") {
            print("Authorization:", token)
        }
        #endif
    }
    
    func log(response: HTTPURLResponse, data: Data) {
        #if DEBUG
        print("Response Status Code:", response.statusCode)
        if let body = String(data: data, encoding: .utf8) {
            print("Response Body:", body)
        }
        #endif
    }
}

protocol ExerciseListRepositoryProtocol {
    func fetchExerciseList() -> AnyPublisher<ExerciseListDomain, NetworkError>
    func undonggiroksaengseong(request: AddExerciseRequestDTO) -> AnyPublisher<Never,NetworkError>
}

struct ExerciseListRepository: ExerciseListRepositoryProtocol {

    
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func fetchExerciseList() -> AnyPublisher<ExerciseListDomain, NetworkError> {
        
        return networkService.request(
            .fetchExerciesList,
                environment: .development
               )
               .eraseToAnyPublisher()
        }
    
    func undonggiroksaengseong(request: AddExerciseRequestDTO) -> AnyPublisher<Never, NetworkError> {
        
        return networkService.request(
            .addExerciseRecord(request)
            , environment: .development
        )
        .eraseToAnyPublisher()
    }
}

struct ExerciseListDomain: Codable {
    let cardio: [String]
    let strength: [String]
    
    enum CodingKeys: String, CodingKey {
        case cardio = "유산소"
        case strength = "근력"
    }
}
