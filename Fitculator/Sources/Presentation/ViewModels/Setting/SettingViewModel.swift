import SwiftUI
import Combine
import PhotosUI

struct UserAccount {
    let email: String
    let name: String
    let token: String
}

struct UserDetails {
    var userNickname: String
    var exerciseIssue: String
    var exerciseGoal: String
    var restingBpm: Int
    var height: Int
    var birth: String
    var device: String
    var profileImage: String
    var gender: String
}

class SettingViewModel: ObservableObject {
    @Published var userAccount: UserAccount = UserAccount(email: "", name: "", token: "")
    @Published var userProfileInfo: UserProfileInfo?
    @Published var tempUserDetails: UserDetails = UserDetails(
        userNickname: "",
        exerciseIssue: "",
        exerciseGoal: "",
        restingBpm: 0,
        height: 0,
        birth: "",
        device: "",
        profileImage: "",
        gender: "Male"
    )
    
    @Published var showImagePicker: Bool = false
    @Published var showCameraPicker: Bool = false
    
    @Published var profileUIImage: UIImage?
    @Published var tempUIImage: UIImage?
    
    @Published var showAlert: Bool = false
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    
    @ObservedObject var languageManager: LanguageManager
    
    @Published var error: Error?
    private var cancellables = Set<AnyCancellable>()
    private let userDetail: UserDetailUseCase
    private let userAccountUseCase: UserAccountUseCase
    private let editUserDetail: EditUserDetailUseCase
    private let uploadProfileImage: UploadProfileImageUseCase
    
    init(userDetailUseCase: UserDetailUseCase, userAccountUseCase: UserAccountUseCase, editUserDetailUseCase: EditUserDetailUseCase, uploadProfileImage: UploadProfileImageUseCase, languageManager: LanguageManager = LanguageManager()) {
        self.languageManager = languageManager
        self.userDetail = userDetailUseCase
        self.userAccountUseCase = userAccountUseCase
        self.editUserDetail = editUserDetailUseCase
        self.uploadProfileImage = uploadProfileImage
        
        fetchUserProfile(userId: 1)
        getUserAccountInfo(email: "qwer@naver.com")
    }
    
    // 이미지 로드 안됨
    func loadProfileImage(from urlString: String) {
        guard let url = URL(string: urlString) else { return }
        
        URLSession.shared.dataTask(with: url) { data, response, error in
            if let error = error {
                DispatchQueue.main.async {
                    self.error = error
                }
                return
            }
            
            guard let data = data, let image = UIImage(data: data) else {
                DispatchQueue.main.async {
                    self.error = NSError(domain: "ImageError", code: 0, userInfo: [NSLocalizedDescriptionKey: "Failed to load image"])
                }
                return
            }
            
            DispatchQueue.main.async {
                self.profileUIImage = image
                self.tempUIImage = image
            }
        }.resume()
    }
    
    func uploadProfileImage(userId: Int, image: UIImage) {
        guard let imageData = image.jpegData(compressionQuality: 0.7) else { return }
        
        uploadProfileImage.execute(userId: userId, imageData: imageData)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.error = error
                    print(error)
                case .finished:
                    break
                }
            }, receiveValue: { response in
                print("Upload response: \(response)")
            })
            .store(in: &cancellables)
    }
    
    func getUserAccountInfo(email: String) {
        userAccountUseCase.execute(email: email)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.error = error
                    print("Error fetching user info: \(error)")
                case .finished:
                    break
                }
            }, receiveValue: { userInfo in
                self.userAccount = UserAccount(email: userInfo.email, name: userInfo.name, token: userInfo.token)
            })
            .store(in: &cancellables)
    }
    
    func fetchUserProfile(userId: Int) {
        userDetail.execute(userId: userId)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.error = error
                case .finished:
                    break
                }
            }, receiveValue: { userProfile in
                self.userProfileInfo = userProfile
                self.tempUserDetails = UserDetails(
                    userNickname: userProfile.userNickname,
                    exerciseIssue: userProfile.exerciseIssue,
                    exerciseGoal: userProfile.exerciseGoal,
                    restingBpm: userProfile.restingBpm,
                    height: userProfile.height,
                    birth: userProfile.birth,
                    device: userProfile.device,
                    profileImage: userProfile.profileImage,
                    gender: userProfile.gender
                )
                self.tempUIImage = nil
                self.loadProfileImage(from: userProfile.profileImage)
            })
            .store(in: &cancellables)
    }
    
    func saveUserProfile(userId: Int) {
        if tempUIImage == nil {
                tempUserDetails.profileImage = ""
        } else if let newImage = tempUIImage, newImage != profileUIImage {
            uploadProfileImage(userId: userId, image: newImage)
        }
        
        let updatedUser = UserProfileInfo(
            userNickname: tempUserDetails.userNickname,
            exerciseIssue: tempUserDetails.exerciseIssue,
            exerciseGoal: tempUserDetails.exerciseGoal,
            restingBpm: tempUserDetails.restingBpm,
            height: tempUserDetails.height,
            birth: tempUserDetails.birth,
            device: tempUserDetails.device,
            profileImage: tempUserDetails.profileImage,
            gender: tempUserDetails.gender
        )
        
        editUserDetail.execute(userId: userId, userInfo: updatedUser)
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    self.error = error
                case .finished:
                    break
                }
            }, receiveValue: { updatedUserInfo in
                self.userProfileInfo = updatedUserInfo
                self.tempUserDetails = UserDetails(
                    userNickname: updatedUserInfo.userNickname,
                    exerciseIssue: updatedUserInfo.exerciseIssue,
                    exerciseGoal: updatedUserInfo.exerciseGoal,
                    restingBpm: updatedUserInfo.restingBpm,
                    height: updatedUserInfo.height,
                    birth: updatedUserInfo.birth,
                    device: updatedUserInfo.device,
                    profileImage: updatedUserInfo.profileImage,
                    gender: updatedUserInfo.gender
                )
            })
            .store(in: &cancellables)
    }
    
    func hasChanges() -> Bool {
        guard let userProfile = userProfileInfo else { return false }
        let tempbirthDate = tempUserDetails.birth.replacingOccurrences(of: "Z", with: "")
        return tempUserDetails.userNickname != userProfile.userNickname ||
        tempUserDetails.height != userProfile.height ||
        tempbirthDate != userProfile.birth ||
        tempUserDetails.restingBpm != userProfile.restingBpm ||
        tempUserDetails.exerciseGoal != userProfile.exerciseGoal ||
        tempUserDetails.exerciseIssue != userProfile.exerciseIssue ||
        tempUIImage != profileUIImage
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
    
    // 운동고민/목표 필터링
    func filterExerciseIndicator(_ input: String) -> String {
        var result = input
        if let firstChar = result.first, firstChar.isWhitespace || (!firstChar.isLetter && !firstChar.isNumber) {
            result.removeFirst()
        }
        let filtered = result.prefix(20)
        return String(filtered)
    }
    
    var isFormValid: Bool {
        let requiredFields = [
            tempUserDetails.userNickname.trimmingCharacters(in: .whitespacesAndNewlines),
            tempUserDetails.exerciseGoal.trimmingCharacters(in: .whitespacesAndNewlines),
            tempUserDetails.exerciseIssue.trimmingCharacters(in: .whitespacesAndNewlines)
        ]
        
        return requiredFields.allSatisfy { $0.isEmpty == false }
    }
    
    // MARK: 언어 변경
    var selectedLanguage: String {
        return languageManager.currentLanguage == "ko" ? "한국어" : "English"
    }
    
    func changeLanguage(to language: String) {
        let newCode = language == "한국어" ? "ko" : "en"
        languageManager.currentLanguage = newCode
        showSettingsAlert(title: "language_changed".localized, message: "languange_apply_message".localized)
    }
    
    func postLanguageNotification() {
        NotificationCenter.default.post(name: NSNotification.Name("LanguageChanged"), object: nil)
    }
}

class LanguageManager: ObservableObject {
    @Published var currentLanguage: String {
        didSet {
            UserDefaults.standard.set(currentLanguage, forKey: "languageCode")
            UserDefaults.standard.set([currentLanguage], forKey: "AppleLanguages")
            objectWillChange.send()
        }
    }
    
    init() {
        self.currentLanguage = LanguageManager.getSavedLanguageCode()
    }
    
    static func getSavedLanguageCode() -> String {
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
