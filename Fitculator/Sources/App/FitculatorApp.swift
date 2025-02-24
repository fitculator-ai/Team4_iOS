import SwiftUI

@main
struct FitculatorApp: App {
    @AppStorage("hasLaunched") private var hasLaunched = false
    @StateObject private var languageManager = LanguageManager()
    @State private var languageUpdate = false
    
    var body: some Scene {
        WindowGroup {
            Group {
                if hasLaunched {
                    NavigationView {
                        MainTabView()
                    }
                } else {
                    IntroView()
                }
            }
            .id(languageUpdate)
            .onReceive(NotificationCenter.default.publisher(for: NSNotification.Name("LanguageChanged"))) { _ in
                languageUpdate.toggle()
            }
        }
    }
}
