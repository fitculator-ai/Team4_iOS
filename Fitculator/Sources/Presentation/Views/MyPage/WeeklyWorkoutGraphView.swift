//
//  WeeklyWorkoutGraphView.swift
//  Fitculator
//
//  Created by MadCow on 2025/2/18.
//

import SwiftUI
import Charts

struct WeeklyWorkoutGraphView: View {
    @ObservedObject var viewModel: MyPageViewModel
    
    var body: some View {
        VStack {
            Chart {
                ForEach(viewModel.thisWeekRecords.indices, id: \.self) { index in
                    let trainingDatas = viewModel.thisWeekRecords[index]
                    
                    ForEach(trainingDatas.indices, id: \.self) { index in
                        let data = trainingDatas[index]
                        if !viewModel.muscleCategory.contains(data.exercise_name) {
                            BarMark(
                                x: .value("Date", data.end_at.components(separatedBy: "T").first!
                                    .stringToDate(format: "yyyy-MM-dd")
                                    .dateToString(includeDay: .onlyDay)),
                                y: .value("Point", data.earned_point)
                            )
                            .foregroundStyle(
                                data.earned_point < 20 ? Color.blue :
                                    data.earned_point >= 20 && data.earned_point < 50 ? Color.yellow :
                                    Color.red
                            )
//                            .annotation(position: .overlay, alignment: .center, spacing: 0) {
//                                if !data.exercise_name.isEmpty {
//                                    VStack {
//                                        Text("\(data.exercise_name)")
//                                            .font(.system(size: 14, weight: .bold))
//                                            .foregroundStyle(Color.white)
//                                            .minimumScaleFactor(0.5)
//                                            .lineLimit(1)
//                                            .allowsTightening(true)
//                                        
//                                        Text("\(data.earned_point, specifier: "%.1f")")
//                                            .font(.system(size: 14, weight: .bold))
//                                            .foregroundStyle(Color.white)
//                                            .minimumScaleFactor(0.5)
//                                            .lineLimit(1)
//                                            .allowsTightening(true)
//                                    }
//                                    .padding(4)
//                                    .background(Color.black.opacity(0.3))
//                                    .clipShape(RoundedRectangle(cornerRadius: 5))
//                                }
//                            }
                            
                            let totalPointMap = viewModel.thisWeekRecords.map {
                                return ($0.first!.end_at.components(separatedBy: "T").first!, $0.filter { !viewModel.muscleCategory.contains($0.exercise_name) }.map { $0.earned_point }.reduce(0, +))
                            }
                            ForEach(totalPointMap, id: \.0) { value in
                                let (date, total) = value
                                PointMark(
                                    x: .value("Date", date.stringToDate(format: "yyyy-MM-dd").dateToString(includeDay: .onlyDay)),
                                    y: .value("total", total)
                                )
                                .annotation(position: .top, alignment: .center, spacing: 0) {
                                    VStack {
                                        if total > 0 {
//                                            ForEach(0..<viewModel.muscleTrainingCount[index], id: \.self) { _ in
//                                                Image(systemName: "dumbbell.fill")
//                                                    .foregroundStyle(Color.white)
//                                            }
                                            Text("\(total, specifier: "%.1f")")
                                                .font(.system(size: 12, weight: .bold))
                                                .foregroundStyle(Color.white)
                                                .minimumScaleFactor(0.5)
                                                .lineLimit(1)
                                                .allowsTightening(true)
                                        }
                                    }
                                }
                                .symbol() {}
                            }
                        }
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
            .chartYScale(domain: 0...viewModel.weeklyMaxPoint)
        }
        .padding()
        .onAppear {
            viewModel.getThisWeekTraining()
        }
    }
}

//#Preview {
//    WeeklyWorkoutGraphView(viewModel: MyPageViewModel())
//}


