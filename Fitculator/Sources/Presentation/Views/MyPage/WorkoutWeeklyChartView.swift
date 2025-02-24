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
                ForEach(viewModel.trainingFatigueDatas.indices, id: \.self) { index in
                    let trainingDatas = viewModel.trainingFatigueDatas[index]
                    let pointSum: Double = trainingDatas.map { $0.gained_point }.reduce(0, +)
                    BarMark(
                        x: .value("Date", "W \(index + 1)"),
                        y: .value("Point", pointSum)
                    )
                    .foregroundStyle(viewModel.selectedWeek == index ? Color.red : Color.blue)
                }
                
                ForEach(viewModel.trainingFatigueDatas.indices, id: \.self) { index in
                    let trainingDatas = viewModel.trainingFatigueDatas[index]
                    let pointSum: Double = trainingDatas.map { $0.gained_point }.reduce(0, +)
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
                                    
                                    let groupedRecords = Dictionary(grouping: viewModel.trainingFatigueDatas[viewModel.selectedWeek ?? viewModel.trainingFatigueDatas.count - 1]) { record in
                                        return record.trainingDate
                                    }
                                    
                                    let sortedGroupedRecords = groupedRecords.keys.sorted().compactMap { date in
                                        groupedRecords[date]
                                    }
                                    
                                    sortedGroupedRecords.forEach {
                                        viewModel.getMaxPoint(records: $0)
                                    }
                                    
                                    viewModel.filteredTrainingCount = sortedGroupedRecords.map { $0.filter { $0.trainingName == "근력운동" }.count }
                                    viewModel.weeklyTrainingData = sortedGroupedRecords
                                    viewModel.setWeekDateStr()
                                }
                            }
                    )
            }
        }
        .padding()
        .onAppear {
            viewModel.fetchAllData(period: .all)
        }
    }
}

//#Preview {
//    WorkoutWeeklyChartView(viewModel: MyPageViewModel())
//}
