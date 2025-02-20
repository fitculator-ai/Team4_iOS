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
    
    @Published var languageCode: String
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    
    init() {
        let savedLanguageCode = SettingViewModel.getSavedLanguageCode()
        self.languageCode = savedLanguageCode
        loadProfileImage()
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
    
    func hasChanges() -> Bool {
        let isSameDate = Calendar.current.isDate(tempUser.birthDate, inSameDayAs: user.birthDate)
        
        return tempUser.nickName != user.nickName ||
        tempUser.height != user.height ||
        !isSameDate ||
        tempUser.restHR != user.restHR ||
        tempUIImage != profileUIImage
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
    
    // 카메라 권한 확인
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
                self.showSettingsAlert(title: "camera_permission_needed".localized, message: "camera_permission_message".localized)
            }
        @unknown default:
            break
        }
    }
    
    // 라이브러리 권한 확인
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
                self.showSettingsAlert(title: "photo_permission_needed".localized, message: "photo_permission_message".localized)
            }
        @unknown default:
            break
        }
    }
    
    // 권한 설정을 위한 이동 alert
    private func showSettingsAlert(title: String, message: String) {
        self.alertTitle = title.localized
        self.alertMessage = message.localized
        self.showAlert = true
    }
    
    // 닉네임 필터링
    func filterNickname(_ input: String) -> String {
        let filtered = input.filter { $0.isLetter || $0.isNumber } // 영문 & 숫자만 허용
        return String(filtered.prefix(10)) // 최대 10자 제한
    }
    
    // MARK: 언어 변경
    var selectedLanguage: String {
        return languageCode == "ko" ? "한국어" : "English"
    }
    
    func changeLanguage(to language: String) {
        if language == "한국어" {
            languageCode = "ko"
        } else {
            languageCode = "en"
        }
        
        // 시스템에 언어 변경 적용
        UserDefaults.standard.set(languageCode, forKey: "languageCode")
        UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
        UserDefaults.standard.synchronize()
        
        // 언어 변경 alert 띄우기 위한 노티
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
    }
    
    // 언어 받아오기
    private static func getSavedLanguageCode() -> String {
        if let savedLanguageCode = UserDefaults.standard.string(forKey: "languageCode") {
            return savedLanguageCode
        } else {
            let deviceLang = Locale.preferredLanguages.first ?? "en"
            let defaultLang = deviceLang.hasPrefix("ko") ? "ko" : "en"
            UserDefaults.standard.set(defaultLang, forKey: "languageCode")
            return defaultLang
        }
    }
}
