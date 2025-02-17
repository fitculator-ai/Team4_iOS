import SwiftUI
import Charts

struct HomeView: View {
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let viewHeight = geometry.size.height
            
            ScrollView(.vertical) {
                VStack(spacing: 10) {
                    WorkoutDonutChart()
                        .frame(height: viewHeight * 0.3)
                    
                    FatigueChart()
                        .frame(width: viewWidth - 20, height: viewHeight * 0.2)
                    
                    WeeklyStrengthReps()
                        .frame(width: viewWidth - 20, height: viewHeight * 0.1)
                    
                    WorkoutHistory()
                        .frame(width: viewWidth - 20, height: viewHeight * 0.3)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
            }
            .background(Color.fitculatorBackgroundColor)
        }
    }
}

// TODO: - 서버 나오면 Domain/Entities에 정의될 User에 맞춰
// https://nilcoalescing.com/blog/UsingMeasurementsFromFoundationAsValuesInSwiftCharts/
struct MockData: Codable, Identifiable {
    
    // MARK: - MockData
    var id = UUID()
    var name: String
    var pct: Double
    
    static func dummyData() -> [MockData] {
        return [
            MockData(name: "테니스", pct: 10),
            MockData(name: "HIIT", pct: 22.3),
            MockData(name: "러닝", pct: 5)
        ]
    }
}

/// 운동량 도넛 차트
struct WorkoutDonutChart: View {

    @State var selectedIndex: Int?
    @State private var chartSize: CGSize = .zero
    
    var body: some View {
        GeometryReader { geometry in
            
            let totalPct = Double(MockData.dummyData().reduce(0) { $0 + $1.pct })
            let remainingPct = max(100 - totalPct, 0)
                        
            let chartData = totalPct < 100
            ? MockData.dummyData() + [MockData(name: "남은 운동량", pct: remainingPct)]
            : MockData.dummyData()
            
            Chart(chartData, id: \.id) { element in
                SectorMark(
                    angle: .value("Pct", element.pct),
                    innerRadius: .ratio(0.6),
                    angularInset: 1
                )
                .cornerRadius(10)
                .foregroundStyle(element.name == "남은 운동량" ? Color.gray.opacity(0.3) : Color.blue)
            }
            .frame(
                width: geometry.size.width,
                height: geometry.size.width * 0.6,
                alignment: .center
            )
            .onAppear {
                chartSize = geometry.size
            }
            .chartBackground { chartProxy in
                // TODO: - 포스언래핑 제거해야함
                let frame = geometry[chartProxy.plotFrame!]
                VStack {
                    Text("\(totalPct, specifier: "%.1f") %")
                        .font(.system(size: geometry.size.width * 0.06))
                        .foregroundStyle(Color.white)
                        .fontWeight(.bold)
                }
                .position(x: frame.midX, y: frame.midY)
            }
            .chartOverlay { chart in
                Rectangle()
                    .fill(.primary.opacity(0.01))
                    .containerShape(.rect)
                    .gesture(
                        DragGesture()
                            .onEnded { _ in
                                selectedIndex = nil
                            }
                            .onChanged { value in
                                
                                guard let plotFrame = chart.plotFrame else {
                                    return
                                }
                                let frame = geometry[plotFrame]
                                let startX = frame.origin.x
                                let currentX = value.location.x - startX
                                                    
                                if let index: Int = chart.value(
                                    atX: currentX
                                ) {
                                    selectedIndex = index
                                }
                            }
                    )
            }
            .chartLegend(.hidden)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
        }
    }
}

/// 포인트 합계(피로도) 차트
struct FatigueChart: View {
    // TODO: - value 운동량 합산으로 변경
    private let fatigueValue = 3.1
    private var maxFatigue: Int {
        let intFatigue = Int(fatigueValue * 100)
        switch intFatigue {
        case 0 ..< 101:
            return 100
        case 101 ..< 201:
            return 200
        case 201 ..< 301:
            return 300
        case 301 ..< 401:
            return 400
        default:
            return 100
        }
    }
    
    var body: some View {
        
        ZStack {
            Text("\(Int(fatigueValue * 100))포인트 운동 과다!🔥")
                .font(.title3)
                .fontWeight(.bold)
                .foregroundColor(.white)
                .offset(y: -40)
            
            WorkoutPointBackgroundLine()
                .trim(from: 0, to: 1)
                .stroke(Color.fatigueBackgroundColor, style: StrokeStyle(lineWidth: 40, lineCap: .round, lineJoin: .round))
                .padding(.leading, 20)
                .padding(.trailing, 20)
            
            ProgressView(value: fatigueValue / 4.0)
                .progressViewStyle(WorkoutPointProgressStyle())
            
            HStack {
                Text("0")
                    .font(.caption)
                    .frame(alignment: .leading)
                    .padding(.leading, 10)
                        
                Spacer()
                Text("\(maxFatigue)") // 100, 200, 300 단위 표시
                    .font(.caption)
                    .frame(alignment: .trailing)
                    .padding(.trailing, 10)
            }
        }
    }
}

/// 달리는 심볼과 라인 스타일
struct WorkoutPointProgressStyle: ProgressViewStyle {

    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0
        let strokeWidth = 25.0
        let strokeColor = Color.fatigueProgressColor
        
        return GeometryReader { geometry in
            let lineWidth = geometry.size.width - 40
            let personPosition = lineWidth * fractionCompleted + 20
                        
            ZStack {
                LineWithRunner()
                    .trim(from: 0, to: fractionCompleted)
                    .stroke(
                        strokeColor,
                        style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round)
                    )
                    .overlay(
                        Image(systemName: "figure.run")
                            .frame(width: 20, height: 20)
                            .position(
                                x: personPosition,
                                y: geometry.size.height / 2
                            )
                    )
            }
        }
    }
}

/// 피로도  선
struct LineWithRunner: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX + 20, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

/// 피로도 백그라운드 선
struct WorkoutPointBackgroundLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

/// 근력 횟수 차트
struct WeeklyStrengthReps: View {
    // MARK: - ForEach사용, 근력 횟수 2회, 운동량에서 근력운도인경우 배경색 변경.
    var body: some View {
        Text("WeeklyStrengthReps")
            .foregroundStyle(Color.white)
    }
}

/// 나의 운동 기록 뷰
struct WorkoutHistory: View {
    // MARK: - List사용 (아직 생각 X)
    var body: some View {
        Text("WorkoutHistory")
            .foregroundStyle(Color.white)
    }
}

#Preview {
    HomeView()
}
