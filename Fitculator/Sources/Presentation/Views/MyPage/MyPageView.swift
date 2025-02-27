import SwiftUI
import Charts
import Kingfisher

struct MyPageView: View {
    @StateObject var viewModel = MyPageViewModel()
    private var settingsService = SettingsService()
    
    init() {
        let appearance = UINavigationBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        appearance.backgroundColor = UIColor(Color.fitculatorBackgroundColor)
        
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
    }
  
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width / 3
            let height = geo.size.height
            
            NavigationStack {
                BackgroundView {
                    ScrollView {
                        VStack(spacing: 10) {
                            // MARK: 프로필 사진
                            VStack(spacing: 0) {
                                NavigationLink {
                                    EditInfoView(
                                        viewModel: settingsService.createViewModel())
                                } label: {
                                    ProfileImageView(viewModel: viewModel, width: width)
                                }
                                
                                Text("\(UserService.shared.user.userNickname)")
                                    .font(.title)
                                    .bold()
                                    .foregroundStyle(.white)
                            }
                            
                            // MARK: 달력 선택
                            /*
                            VStack {
                                SelectCalendarView(viewModel: viewModel, width: width)
                            }
                            .padding()
                            */
                            
                            // MARK: 피로도 그래프
                            VStack {
                                FatigueView(viewModel: viewModel, width: width, height: height)
                            }
                            
                            // MARK: 운동량 기록 그래프들
                            VStack {
                                WorkOutRecordView(viewModel: viewModel, width: width, height: height)
                            }
                            .padding(.bottom, 10)
                        }
                    }
                }
                .onAppear {
                    
                }
                .navigationTitle("my_page".localized)
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: SettingView(
                            viewModel: settingsService.createViewModel()
                            )) {
                                Image(systemName: "gearshape.fill")
                                    .tint(.white)
                        }
                    }
                }
            }
        }
    }
}

struct ProfileImageView: View {
    @ObservedObject var viewModel: MyPageViewModel
    var width: CGFloat
    
    var body: some View {
        Circle()
            .fill(Color.brightBackgroundColor)
            .frame(width: width, height: width)
            .padding()
            .overlay {
                if let profileImage = viewModel.tempUIImage {
                    Image(uiImage: profileImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: width, height: width)
                        .clipShape(Circle())
                } else {
                    Image(systemName: "person")
                        .resizable()
                        .frame(width: width / 3, height: width / 3)
                        .aspectRatio(contentMode: .fit)
                }
            }
            .overlay(alignment: .bottomTrailing) {
                Circle()
                    .fill(Color(UIColor.darkGray))
                    .frame(width: width / 3, height: width / 3)
                    .overlay {
                        Image(systemName: "applepencil.gen1")
                            .foregroundStyle(Color.white)
                    }
                    .padding([.bottom, .trailing], 15)
            }
            .onAppear {
                viewModel.loadProfileImage(from: "https://fitculator4.s3.ap-northeast-2.amazonaws.com/image.jpg")
            }
    }
}

struct SelectCalendarView: View {
    @ObservedObject var viewModel: MyPageViewModel
    var width: CGFloat
    private let height: CGFloat = 30
    
    var body: some View {
        HStack {
            Rectangle()
                .fill(Color.clear)
                .frame(width: width * 1.2, height: height)
                .clipShape(.capsule)
                .overlay(
                    RoundedRectangle(cornerRadius: width * 1.2 / 2)
                        .stroke(Color(UIColor.white), lineWidth: 1)
                )
                .overlay(alignment: .center) {
                    Button {
                        // MARK: TODO - 선택하면 달력 선택
                    } label : {
                        HStack {
                            Text(Date().dateToString(includeDay: .fullMonth))
                                .foregroundStyle(Color.white)
                            Spacer()
                            Image(systemName: "chevron.down")
                                .tint(Color.white)
                        }
                    }
                    .padding()
                }
            
            Spacer()
        }
    }
}

struct FatigueView: View {
    @ObservedObject var viewModel: MyPageViewModel
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text("weekly_record".localized)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.white)
                
                Spacer()
                
                Text("\(viewModel.weekDateStr)")
                    .font(.subheadline)
                    .bold()
                    .foregroundStyle(Color.white)
                    .padding(.top, 10)
            }
            .padding([.leading, .trailing])
            
            Rectangle()
                .fill(Color.brightBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: width * 3 - 30, height: height / 2.5)
                .overlay(alignment: .center, content: {
                    WeeklyWorkoutGraphView(viewModel: viewModel)
                })
        }
    }
}

struct WorkOutRecordView: View {
    @ObservedObject var viewModel: MyPageViewModel
    var width: CGFloat
    var height: CGFloat
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text("weekly_fatigue".localized)
                    .font(.title2)
                    .bold()
                    .foregroundStyle(Color.white)
                Spacer()
            }
            .padding([.top, .leading, .trailing])
            
            Rectangle()
                .fill(Color.brightBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(width: width * 3 - 30, height: height / 2.5)
                .overlay(alignment: .center) {
                    WorkoutWeeklyChartView(viewModel: viewModel)
                }
        }
    }
}
