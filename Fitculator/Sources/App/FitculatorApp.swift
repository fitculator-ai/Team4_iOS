import SwiftUI

@main
struct FitculatorApp: App {
    @AppStorage("hasLaunched") private var hasLaunched = false
    
    init() {
        // 앱 언어 설정
        if let languageCode = UserDefaults.standard.string(forKey: "languageCode") {
            UserDefaults.standard.set([languageCode], forKey: "AppleLanguages")
            UserDefaults.standard.synchronize()
        }
    }
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if hasLaunched {
                    MainTabView()
                } else {
                    IntroView()
                }
            }
        }
    }
}
