import SwiftUI
import PhotosUI

struct ProfileImageSection: View {
    @ObservedObject var viewModel: SettingViewModel
    @State var showActionSheet: Bool = false
    @Binding var isEditing: Bool
    @Binding var tempUIImage: UIImage?
    
    var body: some View {
        Section {
            VStack {
                ZStack {
                    if let profileImage = tempUIImage {
                        Image(uiImage: profileImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 150, height: 150)
                            .clipShape(Circle())
                            .overlay(Circle().stroke(Color.gray, lineWidth: 1))
                            .overlay(alignment: .bottomTrailing) {
                                if isEditing {
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
                                if isEditing {
                                    Image(systemName: "camera.fill")
                                        .foregroundColor(.white)
                                        .padding(12)
                                        .background(Circle().fill(Color.black.opacity(0.5)))
                                }
                            }
                    }
                }
                .onTapGesture {
                    if isEditing {
                        showActionSheet = true
                    }
                }
                .actionSheet(isPresented: $showActionSheet) {
                    ActionSheet(title: Text("change_profile_picture".localized), buttons: [
                        .default(Text("take_photo".localized)) {
                            viewModel.checkPermissions(for: .camera)
                        },
                        .default(Text("choose_from_album".localized)) {
                            viewModel.checkPermissions(for: .photoLibrary)
                        },
                        .destructive(Text("reset_default_image".localized)) {
                            tempUIImage = nil
                        },
                        .cancel()
                    ])
                }
                .alert(viewModel.alertTitle, isPresented: $viewModel.showAlert) {
                    Button("go_to_settings".localized) {
                        if let settingsURL = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(settingsURL)
                        }
                    }
                    Button("cancel".localized, role: .cancel) { }
                } message: {
                    Text(viewModel.alertMessage)
                }
            }
            .frame(maxWidth: .infinity)
            .listRowBackground(Color.clear)
        }
    }
}
