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
            
            // MARK: 안정시 심박수(운동고민, 운동목표 추가 고려중)
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
                .disabled(viewModel.tempUser.nickName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
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
}

struct ProfileImageSection: View {
    @ObservedObject var viewModel: SettingViewModel
    
    var body: some View {
        Section {
            VStack {
                ZStack {
                    if let profileImage = viewModel.tempUIImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            .overlay(alignment: .bottomTrailing) {
                                if viewModel.isEditing {
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Circle().fill(Color.black.opacity(0.5)))
                                }
                            }
                    } else {
                        Circle()
                            .frame(width: 150, height: 150)
                            .foregroundColor(Color.brightBackgroundColor)
                            .overlay(
                                Image(systemName: "person.fill")
                                    .foregroundColor(.white)
                                    .font(.system(size: 40))
                            )
                            .overlay(alignment: .bottomTrailing) {
                                if viewModel.isEditing {
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Circle().fill(Color.black.opacity(0.5)))
                                }
                            }
                    }
                }
                .onTapGesture {
                    if viewModel.isEditing {
                        viewModel.showActionSheet = true
                    }
                }
                .actionSheet(isPresented: $viewModel.showActionSheet) {
                    ActionSheet(title: Text("change_profile_picture".localized), buttons: [
                        .default(Text("take_photo".localized)) {
                            viewModel.checkPermissions(for: .camera)
                        },
                        .default(Text("choose_from_album".localized)) {
                            viewModel.checkPermissions(for: .photoLibrary)
                        },
                        .destructive(Text("reset_default_image".localized)) {
                            viewModel.tempUIImage = nil
                        },
                        .cancel()
                    ])
                }
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
        }
    }
}

#Preview {
    NavigationStack {
        EditInfoView(viewModel: SettingViewModel())
    }
}
