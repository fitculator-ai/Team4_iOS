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
    
    // MARK: 카메라, 사진 권한
    func checkPermissions(for sourceType: UIImagePickerController.SourceType) {
        switch sourceType {
        case .camera:
            checkCameraPermission()
        case .photoLibrary:
            checkPhotoLibraryPermission()
        default:
            break
        }
    }
    
    private func checkCameraPermission() {
        let status = AVCaptureDevice.authorizationStatus(for: .video)
        switch status {
        case .authorized:
            DispatchQueue.main.async {
                self.showCameraPicker = true
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                if granted {
                    DispatchQueue.main.async {
                        self.showCameraPicker = true
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.showSettingsAlert(title: "카메라 권한 필요", message: "카메라를 사용하려면 설정에서 권한을 허용해주세요.")
            }
        @unknown default:
            break
        }
    }
    
    private func checkPhotoLibraryPermission() {
        let status = PHPhotoLibrary.authorizationStatus()
        switch status {
        case .authorized, .limited:
            DispatchQueue.main.async {
                self.showImagePicker = true
            }
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization { newStatus in
                if newStatus == .authorized || newStatus == .limited {
                    DispatchQueue.main.async {
                        self.showImagePicker = true
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.showSettingsAlert(title: "사진 접근 권한 필요", message: "사진을 선택하려면 설정에서 권한을 허용해주세요.")
            }
        @unknown default:
            break
        }
    }
    
    private func showSettingsAlert(title: String, message: String) {
        guard let settingsURL = URL(string: UIApplication.openSettingsURLString) else { return }
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "설정으로 이동", style: .default) { _ in
            UIApplication.shared.open(settingsURL)
        })
        alert.addAction(UIAlertAction(title: "취소", style: .cancel, handler: nil))
        
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let topVC = scene.windows.first?.rootViewController {
            topVC.present(alert, animated: true)
        }
    }
    
    func filterNickname(_ input: String) -> String {
        let filtered = input.filter { $0.isLetter || $0.isNumber } // 영문 & 숫자만 허용
        return String(filtered.prefix(10)) // 최대 10자 제한
    }
}
