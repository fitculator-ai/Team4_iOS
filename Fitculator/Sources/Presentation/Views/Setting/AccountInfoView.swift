import SwiftUI

struct AccountInfoView: View {
    @StateObject private var viewModel = SettingViewModel()
    
    var body: some View {
        VStack {
            List {
                HStack {
                    Text("email".localized)
                    Spacer()
                    Text("\(viewModel.user.userEmail)")
                        .foregroundColor(.gray)
                }
                .listRowBackground(Color.gray.opacity(0.2))
            }
            .background(Color.fitculatorBackgroundColor.opacity(1))
            
            HStack(spacing: 15) {
                Button("logout".localized) {
                    userLogout()
                }
                .foregroundColor(.red)
                
                Button("withdraw".localized) {
                    userWithdraw()
                }
                .foregroundColor(.gray)
            }
            .padding()
        }
        .scrollContentBackground(.hidden)
        .background(Color.fitculatorBackgroundColor.opacity(1))
        .navigationTitle("accountInfo".localized)
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func userLogout() {
        viewModel.userLogout()
    }
    
    private func userWithdraw() {
        viewModel.userWithdraw()
    }
}
