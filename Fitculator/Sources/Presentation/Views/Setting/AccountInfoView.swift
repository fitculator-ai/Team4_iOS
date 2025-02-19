import SwiftUI

struct AccountInfoView: View {
    @StateObject private var viewModel = SettingViewModel()
    
    var body: some View {
        VStack {
            List {
                HStack {
                    Text("이메일")
                    Spacer()
                    Text("\(viewModel.user.userEmail)")
                        .foregroundColor(.gray)
                }
                .listRowBackground(Color.gray.opacity(0.2))
            }
            .background(Color.fitculatorBackgroundColor.opacity(1))
            
            HStack(spacing: 15) {
                Button("로그아웃") {
                    userLogout()
                }
                .foregroundColor(.red)
                
                Button("회원탈퇴") {
                    userWithdraw()
                }
                .foregroundColor(.gray)
            }
            .padding()
        }
        .scrollContentBackground(.hidden)
        .background(Color.fitculatorBackgroundColor.opacity(1))
        .navigationTitle("계정 정보")
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func userLogout() {
        viewModel.userLogout()
    }
    
    private func userWithdraw() {
        viewModel.userWithdraw()
    }
}
