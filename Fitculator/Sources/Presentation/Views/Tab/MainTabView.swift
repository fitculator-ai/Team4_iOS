import SwiftUI

struct MainTabView: View {
    @State var isModalPresented: Bool = false
    init() {
        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(
            Color.fitculatorBackgroundColor
        )
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(
            .tabButtonColor
        )
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(
            .tabButtonColor
        )] // 선택된 탭 텍스트 색상
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor.white // 선택되지 않은 아이콘 색상
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor.white] // 선택되지 않은 탭 텍스트 색상

        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance
    }
    
    var body: some View {
        // MARK: .tabItem은 나중에 deprecate된다고 해서 Tab을 사용했지만 Tab은 iOS 버전 18이상에서만 사용 가능해서 일단 분기처리함
        if #available(iOS 18.0, *) {
            ZStack {
                TabView {
                    Tab("home".localized, systemImage: "house.fill") {
                        BackgroundView {
                            HomeView(
                                viewModel: HomeViewModel(
                                    fetchWorkoutThisWeekHistory: fetchWorkoutThisWeekHistoryUseCase(repository: RepositoryJImpl(dataSource: DataSource())),
                                    fetchWorkoutList: fetchWorkoutListUseCase(repository: RepositoryJImpl(dataSource: DataSource())),
                                    fetchDataForDate: fetchDataForDateUseCase(repository: RepositoryJImpl(dataSource: DataSource()))
                                )
                            )
                        }
                    }
                    Tab("feed".localized, systemImage: "message.fill") {
                        BackgroundView {
                            FeedView()
                        }
                    }
                
                    Tab("", systemImage: "") {

                    }
                
                    Tab("community".localized, systemImage: "person.2.fill") {
                        BackgroundView {
                            CommunityView()
                        }
                    }
                    Tab("my".localized, systemImage: "person.fill") {
                        BackgroundView {
                            MyPageView()
                        }
                    }
                }
            
                Button(action: {
                    self.isModalPresented = true
                }) {
                    Image(systemName: "plus.circle.fill")
                        .resizable()
                        .frame(width: 35, height: 35)
                        .background(Color.white.opacity(0.8))
                        .clipShape(Circle())
                        .shadow(radius: 4)
                        .padding(30)
                }
                .fullScreenCover(isPresented: $isModalPresented) {
                    AddView()
                        .ignoresSafeArea()
                
                }
                .offset(x: 0, y: (UIScreen.main.bounds.height/2)-74)
            }
        }
        else {
            BackgroundView {
                ZStack {
                    TabView {
                        HomeView(
                            viewModel: HomeViewModel(
                                fetchWorkoutThisWeekHistory: fetchWorkoutThisWeekHistoryUseCase(repository: RepositoryJImpl(dataSource: DataSource())),
                                fetchWorkoutList: fetchWorkoutListUseCase(repository: RepositoryJImpl(dataSource: DataSource())),
                                fetchDataForDate: fetchDataForDateUseCase(repository: RepositoryJImpl(dataSource: DataSource()))
                            )
                        )
                        .tabItem {
                            Label("홈", systemImage: "house.fill")
                        }
                        FeedView()
                            .tabItem {
                                Label("피드", systemImage: "message.fill")
                            }
                        AddView()
                            .tabItem {
                                Label("", systemImage: "plus.circle")
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
                    Button(action: {
                        self.isModalPresented = true
                    }) {
                        Image(systemName: "plus.circle.fill")
                            .resizable()
                            .frame(width: 35, height: 35)
                            .background(Color.white.opacity(0.8))
                            .clipShape(Circle())
                            .shadow(radius: 4)
                            .padding(30)
                    }
                    .fullScreenCover(isPresented: $isModalPresented) {
                        AddView()
                            .ignoresSafeArea()
                        
                    }
                    .offset(x: 0, y: (UIScreen.main.bounds.height/2)-74)
                }
                
            }
        }
    }
}

#Preview {
    MainTabView()
}
