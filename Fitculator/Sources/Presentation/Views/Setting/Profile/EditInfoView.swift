import SwiftUI
import PhotosUI

struct EditInfoView: View {
    @ObservedObject var viewModel: SettingViewModel
    @Environment(\.dismiss) private var dismiss
    @State private var showDiscardAlert = false
    
    var body: some View {
        List {
            // MARK: 프로필 이미지
            ProfileImageSection(viewModel: viewModel)
            
            // MARK: 유저 정보
            UserInfoView(viewModel: viewModel)
            
            // MARK: 개인 운동 지표(안정시 심박수, 운동고민, 목표)
            Section {
                HStack {
                    Text("resting_heart_rate".localized)
                    Spacer()
                    if viewModel.isEditing {
                        Picker("", selection: $viewModel.tempUser.restHR) {
                            ForEach(10...100, id: \.self) { restHR in
                                Text("\(restHR) bpm").tag(restHR)
                            }
                        }
                        .pickerStyle(DefaultPickerStyle())
                    } else {
                        Text("\(viewModel.user.restHR)bpm")
                            .foregroundStyle(.gray)
                    }
                }
                .listRowBackground(Color.brightBackgroundColor)
                
                HStack {
                    Text("fitness_concern".localized)
                    Spacer()
                    if viewModel.isEditing {
                        TextField("fitness_concern".localized, text: $viewModel.tempUser.exercise_issue)
                            .textFieldStyle(DefaultTextFieldStyle())
                            .frame(width: 150)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: viewModel.tempUser.exercise_issue) {
                                viewModel.tempUser.exercise_issue = viewModel.filterExerciseIndicator(viewModel.tempUser.exercise_issue)
                            }
                    } else {
                        Text(viewModel.user.exercise_issue)
                            .foregroundStyle(.gray)
                    }
                }
                .listRowBackground(Color.brightBackgroundColor)
                
                HStack {
                    Text("fitness_goal".localized)
                    Spacer()
                    if viewModel.isEditing {
                        TextField("fitness_goal".localized, text: $viewModel.tempUser.exercise_goal)
                            .textFieldStyle(DefaultTextFieldStyle())
                            .frame(width: 150)
                            .multilineTextAlignment(.trailing)
                            .onChange(of: viewModel.tempUser.exercise_goal) {
                                viewModel.tempUser.exercise_goal = viewModel.filterExerciseIndicator(viewModel.tempUser.exercise_goal)
                            }
                    } else {
                        Text(viewModel.user.exercise_issue)
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
        .navigationBarBackButtonHidden(viewModel.isEditing)
        .preferredColorScheme(.dark)
        .toolbar {
            if viewModel.isEditing {
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
                Button(viewModel.isEditing ? "save".localized : "edit".localized) {
                    if viewModel.isEditing {
                        viewModel.updateUserInfo()
                    }
                    viewModel.isEditing.toggle()
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
    }
    
    private func cancelEditing() {
        viewModel.backToExInfo()
        viewModel.isEditing = false
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

#Preview {
    NavigationStack {
        EditInfoView(viewModel: SettingViewModel())
    }
}
