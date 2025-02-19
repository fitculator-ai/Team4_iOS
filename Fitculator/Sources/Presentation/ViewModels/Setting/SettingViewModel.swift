import SwiftUI
import PhotosUI

class SettingViewModel: ObservableObject {
    @Published var isEditing: Bool = false
    
    @Published var user: User = User()
    @Published var tempUser: User = User()
    
    @Published var showImagePicker: Bool = false
    @Published var showCameraPicker: Bool = false
    @Published var showActionSheet: Bool = false
    
    @Published var profileUIImage: UIImage?
    @Published var tempUIImage: UIImage?
    
    init() {
        loadProfileImage()
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
    
    // TODO: 서버 연결 시 전체적으로 다 수정해야 함
    func backToExInfo() {
        tempUser.nickName = user.nickName
        tempUser.height = user.height
        tempUser.birthDate = user.birthDate
        tempUser.restHR = user.restHR
        tempUser.profileImage = user.profileImage
        tempUIImage = profileUIImage
    }
    
    func updateUserInfo() {
        user.nickName = tempUser.nickName
        user.height = tempUser.height
        user.birthDate = tempUser.birthDate
        user.restHR = tempUser.restHR
        
        if let image = tempUIImage {
            if profileUIImage != tempUIImage {
                if let imagePath = saveImageToFile(image) {
                    user.profileImage = imagePath
                    profileUIImage = image
                }
            }
        } else if tempUIImage == nil {
            user.profileImage = nil
            profileUIImage = nil
        }
    }
    
    func userLogout() {
        print("로그아웃")
    }
    
    func userWithdraw() {
        print("탈퇴")
    }
    
    func loadProfileImage() {
        if let imageString = user.profileImage {
            profileUIImage = UIImage(contentsOfFile: imageString)
            tempUIImage = profileUIImage
        } else {
            profileUIImage = nil
            tempUIImage = nil
        }
    }
    
    private func saveImageToFile(_ image: UIImage) -> String? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {
            return nil
        }
        
        let fileName = UUID().uuidString + ".jpg"
        let fileURL = documentsDirectory.appendingPathComponent(fileName)
        
        if let imageData = image.jpegData(compressionQuality: 0.7) {
            try? imageData.write(to: fileURL)
            return fileURL.path
        }
        
        return nil
    }
}
