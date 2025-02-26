import Combine
import Foundation

protocol SettingRepositoryProtocol {
    func getUserAccountInfo(email: String) -> AnyPublisher<UserAccountInfo, NetworkError>
    func getUserDetails(userId: Int) -> AnyPublisher<UserProfileInfo, NetworkError>
    func editUserDetails(userId: Int, userInfo: UserProfileInfo) -> AnyPublisher<UserProfileInfo, NetworkError>
    func uploadProfileImage(userId: Int, imageData: Data) -> AnyPublisher<UploadImageResponse, NetworkError>
}

struct SettingRepository: SettingRepositoryProtocol {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func getUserAccountInfo(email: String) -> AnyPublisher<UserAccountInfo, NetworkError> {
        return networkService.request(.getUserAccountInfo(email: email), environment: .development)
    }
    
    func getUserDetails(userId: Int) -> AnyPublisher<UserProfileInfo, NetworkError> {
        return networkService.request(.getUserDetails(userId: userId), environment: .development)
    }
    
    func editUserDetails(userId: Int, userInfo: UserProfileInfo) -> AnyPublisher<UserProfileInfo, NetworkError> {
        //print(userInfo)
        return networkService.request(.editUserDetails(userId: userId, userInfo: userInfo), environment: .development, method: .put, body: userInfo)
    }
    
    func uploadProfileImage(userId: Int, imageData: Data) -> AnyPublisher<UploadImageResponse, NetworkError> {
        return networkService.uploadMultipartFormData(.uploadProfileImage(userId: userId), environment: .development, imageData: imageData)
    }
}

struct UploadImageResponse: Decodable {
    let message: String
}
