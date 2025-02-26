import Combine
import Foundation

class BaseUseCase {
    let repository: SettingRepository
    
    init(repository: SettingRepository) {
        self.repository = repository
    }
}

class UserAccountUseCase: BaseUseCase {
    func execute(email: String) -> AnyPublisher<UserAccountInfo, NetworkError> {
        return repository.getUserAccountInfo(email: email)
    }
}

class UserDetailUseCase: BaseUseCase {
    func execute(userId: Int) -> AnyPublisher<UserProfileInfo, NetworkError> {
        return repository.getUserDetails(userId: userId)
    }
}

class EditUserDetailUseCase: BaseUseCase {
    func execute(userId: Int, userInfo: UserProfileInfo) -> AnyPublisher<UserProfileInfo, NetworkError> {
        return repository.editUserDetails(userId: userId, userInfo: userInfo)
    }
}

class UploadProfileImageUseCase: BaseUseCase {
    func execute(userId: Int, imageData: Data) -> AnyPublisher<UploadImageResponse, NetworkError> {
        return repository.uploadProfileImage(userId: userId, imageData: imageData)
    }
}
