import SwiftUI
import PhotosUI

class SettingViewModel: ObservableObject {
    @Published var isEditing: Bool = false
    @Published var name: String = "이름"
    @Published var nickname: String = "닉네임"
    @Published var gender: String = "남자"
    @Published var height: Int = 170
    @Published var birthDate: Date = Date()

    @Published var tempNickname: String = ""
    @Published var tempGender: String = ""
    @Published var tempHeight: Int = 0
    @Published var tempBirthDate: Date = Date()

    @Published var profileImage: UIImage? = UIImage(named: "default")
    @Published var showImagePicker: Bool = false
    @Published var showCameraPicker: Bool = false
    @Published var showActionSheet: Bool = false

    func useExInfo() {
        tempNickname = nickname
        tempGender = gender
        tempHeight = height
        tempBirthDate = birthDate
    }
    
    func saveUserInfo() {
        print("정보 수정")
        nickname = tempNickname
        gender = tempGender
        height = tempHeight
        birthDate = tempBirthDate
    }
    
    func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy.MM.dd"
        return formatter.string(from: date)
    }
}
