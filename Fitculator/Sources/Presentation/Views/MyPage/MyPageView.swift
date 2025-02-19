import SwiftUI
import Charts

struct MyPageView: View {
    @StateObject var viewModel = MyPageViewModel()
  
    var body: some View {
        GeometryReader { geo in
            let width = geo.size.width / 3
            let height = geo.size.height
            
            NavigationStack {
                BackgroundView {
                    ScrollView {
                        VStack(spacing: 0) {
                            // MARK: 프로필 사진
                            VStack(spacing: 0) {
                                NavigationLink {
                                    EditInfoView(viewModel: SettingViewModel())
                                } label: {
                                    ProfileImageView(viewModel: viewModel, width: width)
                                }
                                
                                Text("Lucy 님")
                                    .font(.largeTitle)
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
                                WorkOutRecordView(viewModel: viewModel, height: height)
                            }
                            .padding(.bottom, 10)
                        }
                    }
                }
                .onAppear {
                    
                }
                .navigationTitle("My") // TODO: title 색상 흰색으로 변경
                .navigationBarTitleDisplayMode(.inline)
                .toolbar {
                    ToolbarItem(placement: .topBarTrailing) {
                        NavigationLink(destination: SettingView()) {
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
                Image(systemName: "person")
                    .resizable()
                    .frame(width: width / 3, height: width / 3)
                    .aspectRatio(contentMode: .fit)
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
                Text("피로도")
                    .font(.largeTitle)
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
                .frame(width: width * 3, height: height / 2.5)
                .overlay(alignment: .center, content: {
                    WeeklyWorkoutGraphView(viewModel: viewModel)
                })
        }
    }
}

struct WorkOutRecordView: View {
    @ObservedObject var viewModel: MyPageViewModel
    var height: CGFloat
    
    var body: some View {
        VStack(spacing: 5) {
            HStack {
                Text("운동량 기록")
                    .font(.largeTitle)
                    .bold()
                    .foregroundStyle(Color.white)
                Spacer()
            }
            .padding([.top, .leading, .trailing])
            
            Rectangle()
                .fill(Color.brightBackgroundColor)
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .frame(height: height / 2.5)
                .overlay(alignment: .center) {
                    WorkoutWeeklyChartView(viewModel: viewModel)
                }
        }
    }
}

/*
 struct FatigueChartView: View {
     @ObservedObject var viewModel: MyPageViewModel
     
     var body: some View {
         VStack {
             Chart(viewModel.lineGraphMockDatas, id: \.title) { data in
                 LineMark(
                     x: .value("Title", data.title),
                     y: .value("Value", data.value)
                 )
                 .foregroundStyle(.orange)
                 .lineStyle(StrokeStyle(lineWidth: 3))
                 .interpolationMethod(.catmullRom)
                 .symbol() {
                     ZStack {
                         Circle()
                             .fill(Color.orange)
                             .frame(width: 10)

                         if data.title == viewModel.selectedTitle {
                             RoundedRectangle(cornerRadius: 20)
                                 .fill(Color.orange)
                                 .overlay {
                                     Text("\(data.value) %")
                                         .foregroundStyle(Color.white)
                                         .font(.system(size: 12, weight: .bold))
                                 }
                                 .frame(width: 50, height: 25)
                                 .offset(y: data.value < 5 ? -20 : data.value > 95 ? 20 : 0)
                         }
                     }
                 }
             }
             .padding()
             .chartXAxis {
                 AxisMarks { value in
                     AxisValueLabel()
                         
                         .foregroundStyle(Color.white)
                 }
             }
             .chartYAxis {
                 AxisMarks { value in
                     AxisValueLabel()
                         .foregroundStyle(Color.white)
                 }
             }
             .chartOverlay { proxy in
                 Rectangle()
                     .fill(Color.clear)
                     .contentShape(Rectangle())
                     .gesture(
                         DragGesture()
                             .onChanged { value in
                                 let location = value.location
                                 if let selectedDateStr: String = proxy.value(atX: location.x) {
                                     viewModel.selectedTitle = selectedDateStr
                                 }
                             }
                     )
             }
         }
     }
 }
 */
