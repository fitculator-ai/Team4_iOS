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
                // 막대 그래프 위 포인트 총 합을 보여주기 위함 TODO: viewModel로 이동
                let totalPointsByDate = Dictionary(grouping: viewModel.weeklyTrainingData.flatMap { $0 },
                                                   by: { $0.trainingDate })
                    .mapValues { records in
                        return records.filter { $0.trainingName != "근력운동" }.compactMap { $0 }.map { $0.gained_point }.reduce(0, +)
                    }
                    
                ForEach(viewModel.weeklyTrainingData.indices, id: \.self) { index in
                    let trainingDatas = viewModel.weeklyTrainingData[index]
                    
                    ForEach(trainingDatas, id: \.key) { data in
                        if data.trainingName != "근력운동" {
                            BarMark(
                                x: .value("Date", data.trainingDate.dateToString(includeDay: .onlyDay)),
                                y: .value("Point", data.gained_point)
                            )
                            .foregroundStyle(
                                data.gained_point < 20 ? Color.blue :
                                    data.gained_point >= 20 && data.gained_point < 50 ? Color.yellow :
                                    Color.red
                            )
                            .annotation(position: .overlay, alignment: .center, spacing: 0) {
                                if !data.trainingName.isEmpty {
                                    VStack {
                                        Text("\(data.trainingName)")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(Color.white)
                                            .minimumScaleFactor(0.5)
                                            .lineLimit(1)
                                            .allowsTightening(true)
                                        
                                        Text("\(data.gained_point, specifier: "%.1f")")
                                            .font(.system(size: 14, weight: .bold))
                                            .foregroundStyle(Color.white)
                                            .minimumScaleFactor(0.5)
                                            .lineLimit(1)
                                            .allowsTightening(true)
                                    }
                                    .padding(4)
                                    .background(Color.black.opacity(0.3))
                                    .clipShape(RoundedRectangle(cornerRadius: 5))
                                }
                            }
                            
                            ForEach(Array(totalPointsByDate.sorted(by: { $0.key < $1.key }).enumerated()), id: \.element.key) { index, element in
                                let (date, total) = element
                                PointMark(
                                    x: .value("date", date.dateToString(includeDay: .onlyDay)),
                                    y: .value("total", total)
                                )
                                .annotation(position: .top, alignment: .center, spacing: 10) {
                                    VStack {
                                        if total > 0 {
                                            ForEach(0..<viewModel.filteredTrainingCount[index], id: \.self) { _ in
                                                Image(systemName: "dumbbell.fill")
                                                    .foregroundStyle(Color.white)
                                            }
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
            viewModel.fetchWeeklyData(period: .oneWeek)
        }
    }
}

//#Preview {
//    WeeklyWorkoutGraphView(viewModel: MyPageViewModel())
//}


