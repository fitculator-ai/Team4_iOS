import Combine
import Foundation

protocol SettingRepositoryProtocol {
    func getUserAccountInfo(email: String) -> AnyPublisher<UserAccountInfo, NetworkError>
    func getUserDetails(userId: Int) -> AnyPublisher<UserProfileInfo, NetworkError>
    func editUserDetails(userId: Int, userInfo: UserProfileInfo) -> AnyPublisher<UserProfileInfo, NetworkError>
    func uploadProfileImage(userId: Int, imageData: Data) -> AnyPublisher<UploadImageResponse, NetworkError>
}

struct SettingRepository: SettingRepositoryProtocol {
    private let dataSource: SettingDataSource
    
    init(dataSource: SettingDataSource) {
        self.dataSource = dataSource
    }
    
    func getUserAccountInfo(email: String) -> AnyPublisher<UserAccountInfo, NetworkError> {
        return dataSource.getUserAccountInfo(email: email)
    }
    
    func getUserDetails(userId: Int) -> AnyPublisher<UserProfileInfo, NetworkError> {
        return dataSource.getUserDetails(userId: userId)
    }
    
    func editUserDetails(userId: Int, userInfo: UserProfileInfo) -> AnyPublisher<UserProfileInfo, NetworkError> {
        return dataSource.editUserDetails(userId: userId, userInfo: userInfo)
    }
    
    func uploadProfileImage(userId: Int, imageData: Data) -> AnyPublisher<UploadImageResponse, NetworkError> {
        return dataSource.uploadProfileImage(userId: userId, imageData: imageData)
    }
}
