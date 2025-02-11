import SwiftUI

struct MainTabView: View {
    
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(Color.fitculatorBackgroundColor)
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(.tabButtonColor)
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(.tabButtonColor)] // 선택된 탭 텍스트 색상
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.white // 선택되지 않은 아이콘 색상
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white] // 선택되지 않은 탭 텍스트 색상

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some View {
        // MARK: .tabItem은 나중에 deprecate된다고 해서 Tab을 사용했지만 Tab은 iOS 버전 18이상에서만 사용 가능해서 일단 분기처리함
        if #available(iOS 18.0, *) {
            TabView {
                Tab("홈", systemImage: "house.fill") {
                    BackgroundView {
                        HomeView()
                    }
                }
                Tab("피드", systemImage: "message.fill") {
                    BackgroundView {
                        FeedView()
                    }
                }
                Tab("", systemImage: "plus.circle") {
                    BackgroundView {
                        AddView()
                    }
                }
                Tab("커뮤니티", systemImage: "person.2.fill") {
                    BackgroundView {
                        CommunityView()
                    }
                }
                Tab("마이페이지", systemImage: "person.fill") {
                    BackgroundView {
                        MyPageView()
                    }
                }
            }
        } else {
            BackgroundView {
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
                            Label("+", systemImage: "plus.circle")
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
}

#Preview {
    MainTabView()
}
