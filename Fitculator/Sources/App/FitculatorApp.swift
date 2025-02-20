import SwiftUI

@main
struct FitculatorApp: App {
    @AppStorage("hasLaunched") private var hasLaunched = false
    
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
