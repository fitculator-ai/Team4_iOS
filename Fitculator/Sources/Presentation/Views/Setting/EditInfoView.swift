import SwiftUI
import PhotosUI
import UIKit

struct EditInfoView: View {
    @StateObject private var viewModel = SettingViewModel()
    
    var body: some View {
        List {
            Section {
                VStack {
                    Button(action: {
                        viewModel.showActionSheet = true
                    }) {
                        if let image = viewModel.profileImage {
                            Image(uiImage: image)
                                .resizable()
                                .scaledToFill()
                                .frame(width: 200, height: 200)
                                .clipShape(Circle())
                        } else {
                            Circle()
                                .frame(width: 200, height: 200)
                                .foregroundColor(.gray.opacity(0.2))
                                .overlay(
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.white)
                                        .font(.system(size: 40))
                                )
                        }
                    }
                    .actionSheet(isPresented: $viewModel.showActionSheet) {
                        ActionSheet(title: Text("프로필 사진 선택"), buttons: [
                            .default(Text("사진 찍기")) {
                                viewModel.showCameraPicker = true
                            },
                            .default(Text("라이브러리에서 선택")) {
                                viewModel.showImagePicker = true
                            },
                            .cancel() // 현재 사진 없애는 거 추가
                        ])
                    }
                }
                .frame(maxWidth: .infinity)
                .listRowBackground(Color.clear)
            }
            
            Section {
                HStack {
                    Text("이름")
                    Spacer()
                    Text(viewModel.name)
                        .foregroundStyle(.gray)
                }
                .listRowBackground(Color.gray.opacity(0.2))
                
                HStack {
                    Text("닉네임")
                    Spacer()
                    if viewModel.isEditing {
                        TextField("닉네임 입력", text: $viewModel.tempNickname)
                            .textFieldStyle(DefaultTextFieldStyle())
                            .frame(width: 150)
                            .multilineTextAlignment(.trailing)
                    } else {
                        Text(viewModel.nickname)
                            .foregroundStyle(.gray)
                    }
                }
                .listRowBackground(Color.gray.opacity(0.2))
                
                HStack {
                    Text("성별")
                    Spacer()
                    if viewModel.isEditing {
                        Picker("", selection: $viewModel.tempGender) {
                            Text("남자").tag("남자")
                            Text("여자").tag("여자")
                        }
                        .pickerStyle(DefaultPickerStyle())
                    } else {
                        Text(viewModel.gender)
                            .foregroundStyle(.gray)
                    }
                }
                .listRowBackground(Color.gray.opacity(0.2))
                
                HStack {
                    Text("키(cm)")
                    Spacer()
                    if viewModel.isEditing {
                        Picker("", selection: $viewModel.tempHeight) {
                            ForEach(130...250, id: \.self) { height in
                                Text("\(height) cm").tag(height)
                            }
                        }
                        .pickerStyle(DefaultPickerStyle())
                    } else {
                        Text("\(viewModel.height)cm")
                            .foregroundStyle(.gray)
                    }
                }
                .listRowBackground(Color.gray.opacity(0.2))
                
                HStack {
                    Text("생년월일")
                    Spacer()
                    if viewModel.isEditing {
                        DatePicker("", selection: $viewModel.tempBirthDate, displayedComponents: .date)
                    } else {
                        Text(viewModel.formatDate(viewModel.birthDate))
                            .foregroundStyle(.gray)
                    }
                }
            }
            .listRowBackground(Color.gray.opacity(0.2))
        }
        .scrollContentBackground(.hidden)
        .background(Color.fitculatorBackgroundColor.opacity(1))
        .navigationTitle("내 정보")
        .navigationBarTitleDisplayMode(.inline)
        .preferredColorScheme(.dark)
        .toolbar {
            if viewModel.isEditing {
                ToolbarItem(placement: .topBarLeading) {
                    Button("취소") {
                        viewModel.useExInfo()
                        viewModel.isEditing = false
                    }
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button(viewModel.isEditing ? "저장" : "수정") {
                    if viewModel.isEditing {
                        viewModel.saveUserInfo()
                    } else {
                        viewModel.useExInfo()
                    }
                    viewModel.isEditing.toggle()
                }
                .foregroundStyle(.white)
            }
        }
        .sheet(isPresented: $viewModel.showImagePicker) {
            ImagePicker(image: $viewModel.profileImage, sourceType: .photoLibrary)
        }
        .sheet(isPresented: $viewModel.showCameraPicker) {
            ImagePicker(image: $viewModel.profileImage, sourceType: .camera)
        }
    }
    
    struct ImagePicker: UIViewControllerRepresentable {
        @Binding var image: UIImage?
        var sourceType: UIImagePickerController.SourceType
        
        func makeUIViewController(context: Context) -> UIImagePickerController {
            let picker = UIImagePickerController()
            picker.sourceType = sourceType
            picker.delegate = context.coordinator
            picker.allowsEditing = true // 사진 편집 가능
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

#Preview {
    NavigationStack {
        EditInfoView()
    }
}
