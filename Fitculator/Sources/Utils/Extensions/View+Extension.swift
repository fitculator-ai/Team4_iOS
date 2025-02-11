import SwiftUI

struct BackgroundView<Content: View>: View {
    var content: Content
    
    init(@ViewBuilder content: () -> Content) {
        self.content = content()
    }
    
    var body: some View {
        ZStack {
            Color.fitculatorBackgroundColor
                .ignoresSafeArea()
            content
        }
    }
}
