import SwiftUI

struct MainTabView: View {
    
    var body: some View {
        // MARK: .tabItem은 나중에 deprecate된다고 해서 Tab을 사용했지만 Tab은 iOS 버전 18이상에서만 사용 가능해서 일단 분기처리함
        if #available(iOS 18.0, *) {
            TabView {
                Tab("홈", systemImage: "house.fill") {
                    HomeView()
                }
                Tab("피드", systemImage: "message.fill") {
                    FeedView()
                }
                Tab("", systemImage: "plus.circle.fill") {
                    AddView()
                }
                Tab("커뮤니티", systemImage: "person.2.fill") {
                    CommunityView()
                }
                Tab("마이페이지", systemImage: "person.fill") {
                    MyPageView()
                }
            }
        } else {
            TabView {
                HomeView()
                    .tabItem {
                        Label("홈", systemImage: "house.fill")
                    }
                FeedView()
                    .tabItem {
                        Label("피드", systemImage: "message.fill")
                    }
                AddView()
                    .tabItem {
                        Label("+", systemImage: "plus.circle.fill")
                    }
                CommunityView()
                    .tabItem {
                        Label("커뮤니티", systemImage: "person.2.fill")
                    }
                MyPageView()
                    .tabItem {
                        Label("마이페이지", systemImage: "person.fill")
                    }
            }
        }
    }
}

#Preview {
    MainTabView()
}
