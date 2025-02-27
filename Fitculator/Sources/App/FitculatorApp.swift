import SwiftUI

@main
struct FitculatorApp: App {
    @AppStorage("hasLaunched") private var hasLaunched = false
    @StateObject private var languageManager = LanguageManager()
    @State private var languageUpdate = false
    @State var isSplashView = true
    
    var body: some Scene {
        WindowGroup {
            Group {
                if isSplashView{
                    LaunchScreenView()
                        .ignoresSafeArea()
                        .onAppear {
                            DispatchQueue.main.asyncAfter(
                                deadline: DispatchTime.now() + 1) {
                                    isSplashView = false
                            }
                        }
                       
               
                } else {
                    MainTabView()
                }
            }
            .id(languageUpdate)
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
                languageUpdate.toggle()
            }
        }
    }
}


struct LaunchScreenView: UIViewControllerRepresentable {
    func makeUIViewController(context: Context) -> some UIViewController {
        let controller = UIStoryboard(name: "Launch Screen", bundle: nil).instantiateInitialViewController()!
        return controller
    }
    
    func updateUIViewController(_ uiViewController: UIViewControllerType, context: Context) { }
}
