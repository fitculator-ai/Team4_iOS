import SwiftUI
import PhotosUI

struct EditInfoView: View {
    @StateObject private var viewModel = SettingViewModel()
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        List {
            // MARK: 프로필 이미지
            ProfileImageSection(viewModel: viewModel)
            
            // MARK: 유저 정보
            UserInfoView(viewModel: viewModel)
            
            // MARK: 안정시 심박수(운동고민, 운동목표 추가 고려중)
            Section {
                HStack {
                    Text("안정시 심박수")
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
            NavigationLink("계정 정보", destination: AccountInfoView())
                .listRowBackground(Color.brightBackgroundColor)
        }
        .scrollContentBackground(.hidden)
        .background(Color.fitculatorBackgroundColor.opacity(1))
        .navigationTitle("내 정보")
        .navigationBarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(viewModel.isEditing)
        .preferredColorScheme(.dark)
        .toolbar {
            if viewModel.isEditing {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        viewModel.backToExInfo()
                        viewModel.isEditing = false
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(viewModel.isEditing ? "저장" : "수정") {
                    if viewModel.isEditing {
                        viewModel.updateUserInfo()
                    }
                    viewModel.isEditing.toggle()
                }
                .foregroundStyle(.white)
            }
        }
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(image: $viewModel.tempUIImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $viewModel.showCameraPicker) {
            ImagePicker(image: $viewModel.tempUIImage, sourceType: .camera)
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
                    ActionSheet(title: Text("프로필 사진 변경"), buttons: [
                        .default(Text("사진 찍기")) {
                            viewModel.showCameraPicker = true
                        },
                        .default(Text("앨범에서 선택")) {
                            viewModel.showImagePicker = true
                        },
                        .destructive(Text("기본 이미지로 변경")) {
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
        EditInfoView()
    }
}
