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
        }
    }
}

// MARK: - 서버 나오면 Domain/Entities에 정의될 User에 맞춰
struct MockData {
    // MARK: - MockData
    static let workoutData = [
        (name: "테니스", pct: 10),
        (name: "HIIT", pct: 22),
        (name: "러닝", pct: 40),
        (name: "웨이트", pct: 4)
    ]
}

/// 운동량 도넛 차트
struct WorkoutDonutChart: View {
    
    var body: some View {
        GeometryReader { geometry in
            Chart(
                MockData.workoutData, id: \.name) { element in
                    if #available(iOS 17.0, *) {
                        SectorMark(
                            angle: .value("Pct", element.pct),
                            innerRadius: .ratio(0.5),
                            angularInset: 1
                        )
                        .cornerRadius(3.0)
                        .foregroundStyle(by: .value("Name", element.name))
                        .opacity(
                            element.name == MockData.workoutData.first!.name ? 1 : 0.3
                        )
                        
                    } else {
                        //TODO: - iOS 17.0보다 낮은 버전 차트 ...
                    }
                }
                .frame(width: geometry.size.width, height: geometry.size.width * 0.6, alignment: .center)
                .chartBackground { chartProxy in
                    let frame = geometry[chartProxy.plotAreaFrame]
                    VStack {
                        // MARK: - 운동럅 합산 추가.
                        Text("100 %")
                            .font(.system(size: geometry.size.width * 0.06))
                            .fontWeight(.bold)
                    }
                    .position(x: frame.midX, y: frame.midY)
                }
                .chartLegend(.hidden)
                .chartXAxis(.hidden)
                .chartYAxis(.hidden)
        }
    }
}

/// 피로도 차트
struct FatigueChart: View {
    // MARK: - SwiftUI Charts 조금더 학습후 예정 or View 직접 그리기
    var body: some View {
        Text("FatigueChart")
    }
}

/// 근력 횟수 차트
struct WeeklyStrengthReps: View {
    // MARK: - ForEach사용, 근력 횟수 2회, 운동량에서 근력운도인경우 배경색 변경.
    var body: some View {
        Text("WeeklyStrengthReps")
    }
}

/// 나의 운동 기록 뷰
struct WorkoutHistory: View {
    // MARK: - List사용 (아직 생각 X)
    var body: some View {
        Text("WorkoutHistory")
    }
}

#Preview {
    HomeView()
}
