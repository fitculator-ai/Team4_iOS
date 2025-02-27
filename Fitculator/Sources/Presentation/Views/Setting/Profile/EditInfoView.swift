import SwiftUI
import PhotosUI

struct EditInfoView: View {
    @StateObject var viewModel: SettingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDiscardAlert = false
    @State private var isEditing = false
    
    var body: some View {
        List {
            // MARK: 프로필 이미지
            ProfileImageSection(viewModel: viewModel, isEditing: $isEditing, tempUIImage: $viewModel.tempUIImage)
            
            // MARK: 유저 정보
            UserInfoView(userAccount: viewModel.userAccount, userDetails: $viewModel.tempUserDetails, isEditing: $isEditing)
            
            // MARK: 개인 운동 지표(안정시 심박수, 운동고민, 목표)
            Section {
                HStack {
                    Text("resting_heart_rate".localized)
                    Spacer()
                        if isEditing {
                            Picker("", selection: $viewModel.tempUserDetails.restingBpm) {
                                ForEach(10...100, id: \.self) { restHR in
                                    Text("\(restHR) bpm").tag(restHR)
                                }
                            }
                            .pickerStyle(DefaultPickerStyle())
                        } else {
                            Text("\(viewModel.tempUserDetails.restingBpm)bpm")
                                .foregroundStyle(.gray)
                        }
                }
                .listRowBackground(Color.brightBackgroundColor)
                
                HStack {
                    Text("fitness_concern".localized)
                    Spacer()
                    if let user = viewModel.userProfileInfo {
                        if isEditing {
                            TextField("fitness_concern".localized, text: $viewModel.tempUserDetails.exerciseIssue)
                                .textFieldStyle(DefaultTextFieldStyle())
                                .frame(width: 150)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: viewModel.tempUserDetails.exerciseIssue) {
                                    viewModel.tempUserDetails.exerciseIssue = viewModel.filterExerciseIndicator(viewModel.tempUserDetails.exerciseIssue)
                                }
                        } else {
                            Text(user.exerciseIssue)
                                .foregroundStyle(.gray)
                        }
                    } else {
                        Text("Loading...")
                            .foregroundStyle(.gray)
                    }
                }
                .listRowBackground(Color.brightBackgroundColor)
                
                HStack {
                    Text("fitness_goal".localized)
                    Spacer()
                    if let user = viewModel.userProfileInfo {
                        if isEditing {
                            TextField("fitness_goal".localized, text: $viewModel.tempUserDetails.exerciseGoal)
                                .textFieldStyle(DefaultTextFieldStyle())
                                .frame(width: 150)
                                .multilineTextAlignment(.trailing)
                                .onChange(of: viewModel.tempUserDetails.exerciseGoal) {
                                    viewModel.tempUserDetails.exerciseGoal = viewModel.filterExerciseIndicator(viewModel.tempUserDetails.exerciseGoal)
                                }
                        } else {
                            Text(user.exerciseGoal)
                                .foregroundStyle(.gray)
                        }
                    } else {
                        Text("Loading...")
                            .foregroundStyle(.gray)
                    }
                }
                .listRowBackground(Color.brightBackgroundColor)
            }
            
            // MARK: 계정 정보
            NavigationLink("accountInfo".localized, destination: AccountInfoView())
                .listRowBackground(Color.brightBackgroundColor)
        }
        .scrollContentBackground(.hidden)
        .background(Color.fitculatorBackgroundColor.opacity(1))
        .navigationTitle("my_info".localized)
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(isEditing)
        .preferredColorScheme(.dark)
        .toolbar {
            if isEditing {
                ToolbarItem(placement: .topBarLeading) {
                    Button("cancel".localized) {
                        if viewModel.hasChanges() {
                            showDiscardAlert = true
                        } else {
                            cancelEditing()
                        }
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(isEditing ? "save".localized : "edit".localized) {
                    if isEditing {
                        viewModel.saveUserProfile(userId: 1)
                    }
                    isEditing.toggle()
                }
                .disabled(!viewModel.isFormValid)
            }
        }
        .alert("unsaved_changes".localized, isPresented: $showDiscardAlert) {
            Button("exit".localized, role: .destructive) {
                cancelEditing()
            }
            Button("cancel".localized, role: .cancel) {}
        } message: {
            Text("exit_without_saving".localized)
        }
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(image: $viewModel.tempUIImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $viewModel.showCameraPicker) {
            ImagePicker(image: $viewModel.tempUIImage, sourceType: .camera)
        }
        .onAppear {
            viewModel.fetchUserProfile(userId: 1)  // 사용자 프로필 정보를 로드
        }
    }
    
    private func cancelEditing() {
        viewModel.fetchUserProfile(userId: 1)
        isEditing = false
    }
}

// MARK: 사진 설정
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var image: UIImage?
    var sourceType: UIImagePickerController.SourceType
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        picker.allowsEditing = true
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
    
    class Coordinator: NSObject, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let uiImage = info[.editedImage] as? UIImage {
                parent.image = uiImage
            } else if let uiImage = info[.originalImage] as? UIImage {
                parent.image = uiImage
            }
            picker.dismiss(animated: true)
        }
    }
}

//#Preview {
//    NavigationStack {
//        EditInfoView()
//    }
//}
