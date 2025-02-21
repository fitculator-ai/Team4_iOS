import SwiftUI
import AuthenticationServices

struct IntroView: View {
    @StateObject var introViewModel = IntroViewModel()
    @AppStorage("hasLaunched") private var hasLaunched = false
    @State private var navigateToHome = false

    var body: some View {
        VStack {
            Spacer()
            GeometryReader { geometry in
                Image("LogoImage")
                    .resizable()
                    .scaledToFit()
                    .frame(width: geometry.size.width * 0.7)
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
            }
            Spacer()
            
            SignInWithAppleButton(.signIn) { request in
                // Apple 로그인 요청 설정
                request.requestedScopes = [.fullName, .email]
            } onCompletion: { result in
                switch result {
                case .success(let authResults):
                    print("로그인 성공: \(authResults)")
                    if let appleIDCredential = authResults.credential as? ASAuthorizationAppleIDCredential {
                        if let fullName = appleIDCredential.fullName {
                            let firstName = fullName.givenName ?? ""
                            let lastName = fullName.familyName ?? ""
                            print("\(lastName) \(firstName)".trimmingCharacters(in: .whitespaces))
                            introViewModel.userName = "\(lastName) \(firstName)".trimmingCharacters(in: .whitespaces)
                        }
                        introViewModel.userEmail = appleIDCredential.email ?? "이메일 정보 없음"
                        
                        // 최초 로그인 할 때만 userName과 userEmail을 보여줘야하니 앱에 따로 저장해야함
                        print("사용자 ID: \(appleIDCredential.user)")
                        print("이름: \(introViewModel.userName)")
                        print("이메일: \(introViewModel.userEmail)")
                        
                        // appleIDCredential.user 값 keyChain에 저장하고, 다음 앱 실행 부터는 keychain에 값이 있으면 해당 정보 불러와서 다시 로그인 시키면 됨
                    }
                case .failure(let error):
                    print("로그인 실패: \(error.localizedDescription)")
                }
            }
            .padding()
            .frame(height: 80)
            .signInWithAppleButtonStyle(.black)
//            Button(action: {
//                hasLaunched = false
//                navigateToHome = true
//            }) {
//                Text("로그인 하기")
//                    .font(.headline)
//                    .frame(maxWidth: .infinity)
//                    .padding()
//                    .background(Color.brightBackgroundColor)
//                    .foregroundColor(.white)
//                    .cornerRadius(10)
//                    .padding(.horizontal, 40)
//            }
//            .padding(.bottom, 50)
//            .navigationDestination(isPresented: $navigateToHome) {
//                MainTabView()
//            }
        }
        .background(Color.fitculatorBackgroundColor)
        .navigationBarHidden(true)
    }
}
