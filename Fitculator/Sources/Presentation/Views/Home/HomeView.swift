import SwiftUI
import Charts

// TODO: - MyPageView 완성되면 지우기
struct MockData: Identifiable {
    
    // MARK: - MockData
    var id = UUID()
    var name: String
    var pct: Double
    var type: WorkoutType
    
    static func dummyData() -> [MockData] {
        return [
            MockData(name: "테니스", pct: 10, type: .weight),
            MockData(name: "HIIT", pct: 22.3, type: .weight),
            MockData(name: "러닝", pct: 5, type: .cardio)
        ]
    }
}

enum WorkoutType {
    case cardio
    case weight
    case none
}

struct WorkoutData: Identifiable, Equatable {
    let id = UUID()
    let name: String
    let pct: Double // 보정된 운동포인트 값
    let actualPoints: Double // 실제 운동 포인트 값
    let type: WorkoutType
}

struct HomeView: View {
    
    @StateObject var viewModel: HomeViewModel
    
    var body: some View {
        GeometryReader { geometry in
            let viewWidth = geometry.size.width
            let viewHeight = geometry.size.height
            
            ScrollView(.vertical) {
                VStack(spacing: 10) {
                    WorkoutDonutChart(user: viewModel.user)
                        .frame(height: viewHeight * 0.4)
                    
                    FatigueChart()
                        .frame(width: viewWidth - 20, height: viewHeight * 0.13)
                    
                    WeeklyStrengthReps(user: viewModel.user)
                        .frame(width: viewWidth - 20, height: viewHeight * 0.1)
                    
                    WorkoutHistory()
                        .frame(width: viewWidth - 20)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 10)
            }
            .background(Color.fitculatorBackgroundColor)
        }
    }
}

/// 운동량 도넛 차트
struct WorkoutDonutChart: View {

    @State var selectedIndex: Int?
    @State private var chartSize: CGSize = .zero
    @State private var selectedAngle: Double?
    @State var user: User
    @State var activeChartData: [WorkoutData] = []
    @State var originalTotal: Double = 0.0 // 전체 운동량 저장 변수
    @State var totalPct: Double = 0.0 // 차트 운동량을 100을 기준으로 저장되는 변수
    @State var remainingPct: Double = 0.0
    @State var changedTraningRecordsData: [WorkoutData] = []

    var traningRecords: [[Date: [TrainingRecord]]]
        
    init(user: User) {
        self.user = user
        self.traningRecords = user.getTrainingRecords(for: .oneWeek)
        let result = changeTrainingDataForChart(traningRecords)
        self.changedTraningRecordsData = result.data
        self.originalTotal = result.originalTotal
        self.totalPct = changedTraningRecordsData.reduce(0) { $0 + $1.pct }
        self.remainingPct = max(100 - totalPct, 0)
        self.activeChartData = totalPct < 100
        ? changedTraningRecordsData + [WorkoutData(name: "남은 운동량_", pct: remainingPct, actualPoints: remainingPct, type: .none)]
                : changedTraningRecordsData
    }
    
    var body: some View {
        GeometryReader { geometry in
            
            Chart(activeChartData, id: \.id) { element in
                let index = activeChartData.firstIndex(where: { $0.id == element.id })

                SectorMark(
                    angle: .value("Pct", element.pct),
                    innerRadius: .ratio(0.5),
                    angularInset: 1
                )
                .cornerRadius(40)
                .foregroundStyle(element.name == "남은 운동량_" ? Color.gray.opacity(0.3) : Color.blue)
                .opacity(selectedIndex == nil || selectedIndex == index ? 1.0 : 0.4)
            }
            .chartAngleSelection(value: $selectedAngle)
            .frame(
                width: geometry.size.width,
                height: geometry.size.width * 0.8,
                alignment: .center
            )
            .onAppear {
                chartSize = geometry.size
                updateActiveChartData()
            }
            .chartBackground { chartProxy in
                if let plotFrame = chartProxy.plotFrame {
                    let frame = geometry[plotFrame]
                    VStack {
                        if let index = selectedIndex {
                            let selectedData = activeChartData[index]
                            
                            // 운동량 총합이 100이 넘으면 100을 기준으로 각 운동 포인트가 보정된 값이 나와 분기 처리.
                            let _ = print("선택된 운동: \(selectedData.name) 운동량: \(selectedData.actualPoints) \n")
                            Text("\(String(selectedData.name.split(separator: "_").first ?? "")) \n \(selectedData.actualPoints, specifier: "%.1f")P")                                .font(.system(size: geometry.size.width * 0.07))
                                .foregroundStyle(Color.white)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                            
                        } else {
                            Text("\(originalTotal, specifier: "%.1f")P")
                                .font(.system(size: geometry.size.width * 0.07))
                                .foregroundStyle(Color.white)
                                .fontWeight(.bold)
                                .multilineTextAlignment(.center)
                        }
                    }
                    .position(x: frame.midX, y: frame.midY)
                }
            }
            .chartOverlay { chart in
                getChartOverlay(chart: chart, geometry: geometry, data: activeChartData)
            }
            .onAppear() {
                updateActiveChartData()
            }
            .onChange(of: activeChartData) {
                updateActiveChartData()
            }
            .chartLegend(.hidden)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
        }
    }
    
    func updateActiveChartData() {
        let result = changeTrainingDataForChart(traningRecords)
        self.changedTraningRecordsData = result.data
        self.originalTotal = result.originalTotal
        self.totalPct = changedTraningRecordsData.reduce(0) { $0 + $1.pct }
        self.remainingPct = max(100 - totalPct, 0)

        if totalPct < 100 {
            self.activeChartData = changedTraningRecordsData + [
                WorkoutData(name: "남은 운동량_", pct: remainingPct, actualPoints: remainingPct, type: .none)
            ]
        } else {
            self.activeChartData = changedTraningRecordsData
        }
    }
    
    func getChartOverlay(chart: ChartProxy, geometry: GeometryProxy, data: [WorkoutData]) -> some View {
        Rectangle()
            .fill(Color.clear)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { value in
                        guard let plotFrame = chart.plotFrame else { return }
                        let frame = geometry[plotFrame]
                        let center = CGPoint(x: frame.midX, y: frame.midY)
                        
                        // 터치 위치와 중심 사이의 벡터 계산
                        let dx = value.location.x - center.x
                        let dy = value.location.y - center.y
                        let distance = sqrt(dx * dx + dy * dy)
                        
                        // 차트의 반지름 계산
                        let outerRadius = min(frame.width, frame.height) / 2
                        let innerRadius = outerRadius * 0.5
                        
                        // 도넛 영역 확인
                        guard distance >= innerRadius && distance <= outerRadius else {
                            selectedIndex = nil
                            return
                        }
                        
                        // 각도 계산 (12시 방향이 0도, 시계방향으로 증가)
                        var angleInRadians = atan2(dx, -dy) // x와 -y를 사용하여 12시 방향을 0도로 설정
                        if angleInRadians < 0 {
                            angleInRadians += 2 * .pi
                        }
                        
                        // 각도를 0-360도로 변환
                        let angleInDegrees = angleInRadians * 180 / .pi
                        
                        // 섹터 찾기
                        var cumulativeAngle: Double = 0
                        for (index, element) in activeChartData.enumerated() {
                            let sectorAngle = (element.pct / 100) * 360
                            let nextAngle = cumulativeAngle + sectorAngle
                            
                            // 각도가 현재 섹터 범위 내에 있는지 확인
                            if angleInDegrees >= cumulativeAngle && angleInDegrees < nextAngle {
                                selectedIndex = index
                                break
                            }
                            cumulativeAngle = nextAngle
                        }
                    }
                    .onEnded { _ in
                        selectedIndex = nil
                    }
            )
    }
}

/// [[Date: [TrainingRecord]]] -> [WorkoutData]
func changeTrainingDataForChart(_ records: [[Date: [TrainingRecord]]]) -> (data: [WorkoutData], originalTotal: Double) {
    var dataDict: [String: Double] = [:]
    
    for week in records {
        for (_, dailyRecords) in week {
            for record in dailyRecords {
                let key = "\(record.trainingName)_\(record.gained_point)"
                dataDict[key, default: 0] += record.gained_point
            }
        }
    }
    
    let originalTotal = dataDict.values.reduce(0, +) // 전체 운동량의 총합
    let total = dataDict.values.reduce(0, +) // 비율 조정을 위한 totalPct
    
    // 전체 합이 100을 넘는 경우, 100을 기준으로 비율 조정
    var result: [WorkoutData] = []
    if originalTotal > 100 {
        result = dataDict.map { (key, value) -> WorkoutData in
            let adjustedPct = value / total * 100  // 전체 합이 100을 초과하면 비율을 조정
            return WorkoutData(name: key, pct: adjustedPct, actualPoints: value, type: .weight)
        }
    } else {
        result = dataDict.map { (key, value) -> WorkoutData in
            return WorkoutData(
                name: key,
                pct: value, actualPoints: value,
                type: .weight
            )
        }
    }
    
    return (result, originalTotal)
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
                    .foregroundStyle(Color.white)
                    .frame(alignment: .leading)
                    .padding(.leading, 10)
                        
                Spacer()
                Text("\(maxFatigue)") // 100, 200, 300 단위 표시
                    .font(.caption)
                    .foregroundStyle(Color.white)
                    .frame(alignment: .trailing)
                    .padding(.trailing, 10)
            }
            .offset(y: 30)
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

struct WorkoutCountLine: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.midY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.midY))
        return path
    }
}

/// 근력 횟수 차트
struct WeeklyStrengthReps: View {
    
    @State var user: User
    
    var traningRecords: [[Date: [TrainingRecord]]]
    // traningRecords 데이터 변환
    var changedTraningRecordsData: [WorkoutData]
    var weightCount: Int
    
    init(user: User) {
        self.user = user
        self.traningRecords = user.getTrainingRecords(for: .oneWeek)
        let result = changeTrainingDataForChart(traningRecords)
        self.changedTraningRecordsData = result.data
        self.weightCount = changedTraningRecordsData.filter { $0.type == WorkoutType.weight }.count
        
    }
    
    var body: some View {
       
        ZStack {
            HStack {
                Text("근력")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .offset(y: -40)
                Spacer()
                Text("\(weightCount) / 2")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .offset(y: -40)
            }
            WorkoutPointBackgroundLine()
                .trim(from: 0, to: 1)
                .stroke(
                    Color.fatigueBackgroundColor,
                    style: StrokeStyle(
                        lineWidth: 40,
                        lineCap: .round,
                        lineJoin: .round
                    )
                )
                .padding(.leading, 20)
                .padding(.trailing, 20)
            HStack{
                WorkoutCountLine()
                    .trim(from: 0, to: 1)
                    .stroke(
                        Color.gray,
                        style: StrokeStyle(
                            lineWidth: 25,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                WorkoutCountLine()
                    .trim(from: 0, to: 1)
                    .stroke(
                        Color.gray,
                        style: StrokeStyle(
                            lineWidth: 25,
                            lineCap: .round,
                            lineJoin: .round
                        )
                    )
                    .padding(.leading, 20)
                    .padding(.trailing, 20)
                
            }
            HStack {
                ForEach(0..<2, id: \.self) { index in
                    WorkoutCountLine()
                        .trim(from: 0, to: 1)
                        .stroke(
                            index < weightCount ? Color.blue : Color.gray,
                            style: StrokeStyle(
                                lineWidth: 25,
                                lineCap: .round,
                                lineJoin: .round
                            )
                        )
                        .padding(.leading, index == 0 ? 20: 10)
                        .padding(.trailing, index == 0 ? 10 : 20)
                }
            }
        }
    }
}

/// 나의 운동 기록 뷰
struct WorkoutHistory: View {
    
    let workouts = [
        WorkoutListCell(
            workoutType: "달리기",
            workoutDate: "11.18 오후 6:41",
            workoutPoints: 12,
            averageHeartRate: 90,
            calories: 90,
            duration: 30,
            intensity: "매우낮음",
            intensityColor: Color.yellow,
            iconName: "figure.run"
        ),
        WorkoutListCell(
            workoutType: "자전거",
            workoutDate: "11.20 오전 7:30",
            workoutPoints: 18,
            averageHeartRate: 105,
            calories: 150,
            duration: 40,
            intensity: "보통",
            intensityColor: Color.green,
            iconName: "bicycle"
        ),
        WorkoutListCell(
            workoutType: "자전거",
            workoutDate: "11.20 오전 7:30",
            workoutPoints: 18,
            averageHeartRate: 105,
            calories: 150,
            duration: 40,
            intensity: "보통",
            intensityColor: Color.green,
            iconName: "bicycle"
        )
    ]
    
    var body: some View {
        ScrollView{
            VStack(spacing: 10) {
                ForEach(workouts, id: \.workoutType) { workout in
                    workout
                }
            }
        }
    }
}

// 운동 리스트 Cell
struct WorkoutListCell: View {
    var workoutType: String
    var workoutDate: String
    var workoutPoints: Int
    var averageHeartRate: Int
    var calories: Int
    var duration: Int
    var intensity: String
    var intensityColor: Color
    var iconName: String 
    
    var body: some View {
        VStack {
            HStack {
                HStack {
                    Image(systemName: iconName)
                        .font(.title2)
                        .frame(width: 40, height: 40)
                        .background(Color.purple.opacity(0.8))
                        .clipShape(Circle())
                        .foregroundColor(.white)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        HStack {
                            Text(workoutType)
                                .font(.headline)
                                .bold()
                                .foregroundColor(.white)
                            Spacer()
                            Text("\(workoutPoints) pt")
                                .font(.title3)
                                .bold()
                                .foregroundColor(.white.opacity(0.8))
                        }
                        Text(workoutDate)
                            .font(.subheadline)
                            .foregroundColor(.gray)
                    }
                }
            }
            
            Divider()
                .background(Color.gray.opacity(0.5))
            
            HStack {
                WorkoutDetailView(
                    title: "평균 심박",
                    value: "\(averageHeartRate) bpm"
                )
                Spacer()
                WorkoutDetailView(title: "칼로리", value: "\(calories) kcal")
                Spacer()
                WorkoutDetailView(title: "시간", value: "\(duration) min")
                Spacer()
                WorkoutDetailView(
                    title: "강도",
                    value: intensity,
                    textColor: intensityColor
                )
            }
            .padding(.top, 5)
        }
        .padding()
        .background(Color.purple.opacity(0.6))
        .clipShape(RoundedRectangle(cornerRadius: 15))
    }
}

/// 운동 리스트 Cell 서브 뷰
struct WorkoutDetailView: View {
    var title: String
    var value: String
    var textColor: Color = .white
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(title)
                .font(.caption)
                .foregroundColor(.gray)
                
            Text(value)
                .font(.subheadline)
                .bold()
                .foregroundColor(textColor)
        }
    }
}

//#Preview {
//    WorkoutListCell(
//        workoutType: "달리기",
//        workoutDate: "11.18 오후 6:41",
//        workoutPoints: 12,
//        averageHeartRate: 90,
//        calories: 90,
//        duration: 30,
//        intensity: "매우낮음",
//        intensityColor: Color.yellow,
//        iconName: "figure.run"
//    )
//}

#Preview {
    HomeView(viewModel: HomeViewModel(fetchUseCase: UseCase(dataSource: DataSource())))
}
