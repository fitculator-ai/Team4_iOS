import SwiftUI

struct AccountInfoView: View {
    @StateObject var viewModel = AccountInfoViewModel(userAccountUseCase: UserAccountUseCase(repository: SettingRepository(networkService: NetworkService(session: .shared))))
    
    var body: some View {
        VStack {
            List {
                HStack {
                    Text("email".localized)
                    Spacer()
                    if let user = viewModel.user {
                        Text("\(user.email)")
                            .foregroundColor(.gray)
                    } else {
                        Text("Loading...")
                            .onAppear {
                                viewModel.getUserAccountInfo(email: "qwer@naver.com")
                            }
                    }
                }
                .listRowBackground(Color.gray.opacity(0.2))
            }
            .background(Color.fitculatorBackgroundColor.opacity(1))
            
            HStack(spacing: 15) {
                Button("logout".localized) {
                    viewModel.userLogout()
                }
                .foregroundColor(.red)
                
                Button("withdraw".localized) {
                    viewModel.userWithdraw()
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
}
