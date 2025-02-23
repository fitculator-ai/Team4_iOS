import SwiftUI
import Charts

/// 포인트 합계(피로도) 차트
struct FatigueChart: View {
    @State var user: User
    @State var fatigueValue: Double = 0.0
    @State var changedTraningRecordsData: [WorkoutData] = []
    @State var traningRecords: [[Date: [TrainingRecord]]] = []
    @State var isTooltipVisible: Bool = false
    
    private var maxFatigue: Int = 100
    
    private var fatigueMessage: String {
        let intFatigue = Int(fatigueValue * 100)
        switch intFatigue {
        case 0..<101: return "적정한 운동량 💪"
        case 101..<201: return "운동 과다!🔥"
        case 201..<301: return "너무 무리했어요! 🛑"
        default: return "과로 상태 ⚠️"
        }
    }
    
    private var progressColor: Color {
            let intFatigue = Int(fatigueValue * 100)
            switch intFatigue {
            case 0..<101: return Color.green
            case 101..<201: return Color.yellow
            case 201..<301: return Color.orange
            default: return Color.red
            }
        }
    
    init(user: User) {
        self.user = user
    }
    
    var body: some View {
        
        ZStack {
            
            HStack {
                
                // TODO: - 각 포인트별 멘트 다르게 바꾸기.
                Text("\(Int(fatigueValue * 100))포인트 \(fatigueMessage)")
                    .font(.title3)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .offset(y: -40)
                
                Spacer()
                
                Button {
                    isTooltipVisible = true
                    DispatchQueue.main
                        .asyncAfter(deadline: .now() + 3) {
                            isTooltipVisible = false
                        }
                } label: {
                    Image(systemName: "questionmark.circle.fill")
                        .foregroundStyle(.gray)
                }
                .offset(y: -40)
                
            }
            WorkoutPointBackgroundLine()
                .trim(from: 0, to: 1)
                .stroke(Color.fatigueBackgroundColor, style: StrokeStyle(lineWidth: 40, lineCap: .round, lineJoin: .round))
                .padding(.leading, 20)
                .padding(.trailing, 20)
            
            ProgressView(value: min(1.0, fatigueValue))
                .progressViewStyle(WorkoutPointProgressStyle(progressColor: progressColor))
                .padding(.trailing, 20)
            
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
            
            if isTooltipVisible {
                TooltipBody()
                    .padding(.leading, 80)
                    .padding(.top, 5)
                    .zIndex(999)
                    .offset(x: 0, y: -100)
                    .transition(.opacity) // 애니메이션 효과 추가
            }
            
        }// ZStack
        .onAppear {
            UpdateFatigueChartProperties()
        }
    }
    
    func UpdateFatigueChartProperties() {
        self.traningRecords = user.getTrainingRecords(for: .oneWeek)
        let result = changeTrainingDataForChart(traningRecords)
        self.changedTraningRecordsData = result.data
        self.fatigueValue = (result.originalTotal) / 100
    }
}

/// 달리는 심볼과 라인 스타일
struct WorkoutPointProgressStyle: ProgressViewStyle {
    
    let progressColor: Color

    func makeBody(configuration: Configuration) -> some View {
        let fractionCompleted = configuration.fractionCompleted ?? 0
        let strokeWidth = 25.0
        
        return GeometryReader { geometry in
            let lineWidth = geometry.size.width - 20
            let personPosition = lineWidth * fractionCompleted + 20
                        
            ZStack {
                LineWithRunner()
                    .trim(from: 0, to: fractionCompleted)
                    .stroke(
                        progressColor,
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

// MARK: - ToolTip
public struct CustomTriangleShape: Shape {
    private var width:  CGFloat
    private var height:  CGFloat
    private var radius:  CGFloat
    
    public init(width: CGFloat = 23, height: CGFloat = 25, radius: CGFloat = 1) {
        self.width = width
        self.height = height
        self.radius = radius
    }
    
    public func path(in rect: CGRect) -> Path {
        var path = Path()
        
        path.move(to: CGPoint(x: rect.minX + width / 2 - radius, y: rect.minY))
        path.addQuadCurve(
            to: CGPoint(x: rect.minX + width / 2 + radius, y: rect.minY),
            control: CGPoint(x: rect.minX + width / 2, y: rect.minY + radius)
        )
        path.addLine(to: CGPoint(x: rect.minX + width, y: rect.minY + height))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.minY + height))
        
        path.closeSubpath()
        
        return path
    }
}

struct TooltipBody: View {
    let tooltipText: String = """
100 포인트: 권장 일주일 운동량
100~200 포인트: 운동을 좋아하시는군요?
200~300 포인트: 부상 조심~
300 포인트 이상 : 운동 중독!
"""
    
    var body: some View {
            VStack {
                Text(tooltipText)
                    .font(.callout)
                    .foregroundStyle(Color.white)
                    .padding(.vertical, 16)
                    .padding(.horizontal, 16)
                    .fixedSize(horizontal: false, vertical: true)
                    .background(
                        Rectangle()
                            .fill(Color.brightBackgroundColor)
                            .cornerRadius(16)
                            .opacity(0.8)
                    )
            }
    }
}

