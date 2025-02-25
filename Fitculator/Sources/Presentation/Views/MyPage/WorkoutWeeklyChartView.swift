//
//  WorkoutWeeklyChartView.swift
//  Fitculator
//
//  Created by MadCow on 2025/2/19.
//

import SwiftUI
import Charts

struct WorkoutWeeklyChartView: View {
    @ObservedObject var viewModel: MyPageViewModel
    
    var body: some View {
        VStack {
            Chart {
                ForEach(viewModel.last25WeeksRecords.indices, id: \.self) { index in
                    let trainingDatas = viewModel.last25WeeksRecords[index]
                    let pointSum: Double = trainingDatas.map { $0.earned_point }.reduce(0, +)
                    BarMark(
                        x: .value("Date", "W \(index + 1)"),
                        y: .value("Point", pointSum)
                    )
                    .foregroundStyle(viewModel.selectedWeek == index ? Color.red : Color.blue)
                }
                
                ForEach(viewModel.last25WeeksRecords.indices, id: \.self) { index in
                    let trainingDatas = viewModel.last25WeeksRecords[index]
                    let pointSum: Double = trainingDatas.map { $0.earned_point }.reduce(0, +)
                    LineMark(
                        x: .value("Date", "W \(index + 1)"),
                        y: .value("Point", pointSum * 1.5)
                    )
                    .foregroundStyle(Color.red)
                    .symbol {
                        Circle()
                            .fill(Color.red)
                            .frame(width: 5, height: 5)
                    }
                }
            }
            .chartXAxis {
                AxisMarks { _ in
                    AxisValueLabel()
                        .foregroundStyle(Color.white)
                }
            }
            .chartYAxis {
                AxisMarks { _ in
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
                                    let index = Int(selectedDateStr.components(separatedBy: " ").last!)! - 1
                                    viewModel.selectedWeek = index
                                    
                                    let groupedRecords = Dictionary(grouping: viewModel.last25WeeksRecords[viewModel.selectedWeek ?? viewModel.last25WeeksRecords.count - 1]) { record in
                                        return record.end_at.components(separatedBy: "T").first!
                                    }
                                    
                                    let sortedGroupedRecords = groupedRecords.keys.sorted().compactMap { date in
                                        groupedRecords[date]
                                    }
                                    
                                    sortedGroupedRecords.forEach {
                                        viewModel.getMaxPoint(records: $0)
                                    }
                                    
                                    viewModel.muscleTrainingCount = sortedGroupedRecords.map { $0.filter { viewModel.muscleCategory.contains($0.exercise_name) }.count }
                                    viewModel.thisWeekRecords = sortedGroupedRecords
                                    viewModel.setWeekDateStr()
                                }
                            }
                    )
            }
        }
        .padding()
        .onAppear {
            viewModel.get25WeekTraining()
        }
    }
}

//#Preview {
//    WorkoutWeeklyChartView(viewModel: MyPageViewModel())
//}
