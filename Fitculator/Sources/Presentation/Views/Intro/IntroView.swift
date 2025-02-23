import SwiftUI

struct IntroView: View {
    @AppStorage("hasLaunched") private var hasLaunched = false
    @State private var navigateToHome = false

    var body: some View {
        NavigationStack {
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
                
                Button(action: {
                    hasLaunched = true
                    navigateToHome = true
                }) {
                    Text("login".localized)
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.brightBackgroundColor)
                        .foregroundColor(.white)
                        .cornerRadius(10)
                        .padding(.horizontal, 40)
                }
                .padding(.bottom, 50)
                .navigationDestination(isPresented: $navigateToHome) {
                    MainTabView()
                }
            }
            .background(Color.fitculatorBackgroundColor)
            .navigationBarHidden(true)
        }
    }
}
