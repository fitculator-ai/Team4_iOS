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
//            ScrollView(.horizontal) {
                Chart {
                    // 막대 그래프 위 포인트 총 합을 보여주기 위함
                    let totalPointsByDate = Dictionary(grouping: viewModel.weeklyTrainingData.flatMap { $0 },
                                                       by: { $0.trainingDate })
                        .mapValues { records in
                            records.reduce(0) { $0 + $1.gained_point }
                        }
                        
                    ForEach(viewModel.weeklyTrainingData.indices, id: \.self) { index in
                        let trainingDatas = viewModel.weeklyTrainingData[index]
                        
                        ForEach(trainingDatas, id: \.key) { data in
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
                            
                            ForEach(totalPointsByDate.sorted(by: { $0.key < $1.key }), id: \.key) { date, total in
                                PointMark(
                                    x: .value("date", date.dateToString(includeDay: .onlyDay)),
                                    y: .value("total", total)
                                )
                                .annotation(position: .top, alignment: .center, spacing: 10) {
                                    if total > 0 {
                                        Text("\(total, specifier: "%.1f")")
                                            .font(.system(size: 12, weight: .bold))
                                            .foregroundStyle(Color.white)
                                            .minimumScaleFactor(0.5)
                                            .lineLimit(1)
                                            .allowsTightening(true)
                                    }
                                }
                                .symbol() {}
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
//                .frame(width: CGFloat(viewModel.weeklyTrainingData.count) * 80)
//            }
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


