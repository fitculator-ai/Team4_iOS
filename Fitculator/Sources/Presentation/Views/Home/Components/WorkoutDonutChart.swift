import SwiftUI
import Charts

/// 운동량 도넛 차트
struct WorkoutDonutChart: View {

    @State var selectedIndex: Int?
    @State private var chartSize: CGSize = .zero
    @State private var selectedAngle: Double?
    var originalTotal: Double = 0.0 // 전체 운동량 저장 변수
    var totalPct: Double = 0.0 // 차트 운동량을 100을 기준으로 저장되는 변수
    var remainingPct: Double = 0.0
    var changedTraningRecordsData: [WorkoutData] = []

    var traningRecords: [[Date: [TrainingRecord]]] = []
    var activeChartData: [WorkoutData] = []
        
    init(
        originalTotal: Double,
        totalPct: Double,
        remainingPct: Double,
        changedTraningRecordsData: [WorkoutData],
        traningRecords: [[Date : [TrainingRecord]]],
        activeChartData: [WorkoutData]
    ) {
        self.originalTotal = originalTotal
        self.totalPct = totalPct
        self.remainingPct = remainingPct
        self.changedTraningRecordsData = changedTraningRecordsData
        self.traningRecords = traningRecords
        self.activeChartData = activeChartData
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
                .cornerRadius(8)
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
            }
            .chartBackground { chartProxy in
                if let plotFrame = chartProxy.plotFrame {
                    let frame = geometry[plotFrame]
                    VStack {
                        if let index = selectedIndex {
                            let selectedData = activeChartData[index]
                            
                            // 운동량 총합이 100이 넘으면 100을 기준으로 각 운동 포인트가 보정된 값이 나와 분기 처리.
                            let _ = print("선택된 운동: \(selectedData.name) 운동량: \(selectedData.actualPoints) 운동시간: \(selectedData.duration) \n")
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
            .chartLegend(.hidden)
            .chartXAxis(.hidden)
            .chartYAxis(.hidden)
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
