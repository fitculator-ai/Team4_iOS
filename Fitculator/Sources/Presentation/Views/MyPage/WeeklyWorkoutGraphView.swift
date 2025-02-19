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
                let weekData = viewModel.user.getTrainingRecords(for: .oneWeek)
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel()
                        .foregroundStyle(Color.white)
                }
            }
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel()
                        .foregroundStyle(Color.white)
                }
            }
        }
        .padding()
        .background(Color.fitculatorBackgroundColor)
        .onAppear {
            viewModel.user.getTrainingRecords(for: .oneWeek).forEach {
                $0.sorted { $0.key < $1.key }.forEach {
                    $0.value.forEach { print ($0) }
                    print("============================")
                }
            }
        }
    }
}

#Preview {
    WeeklyWorkoutGraphView(viewModel: MyPageViewModel())
}


//                        ForEach(totalPointsByDate.sorted(by: { $0.key < $1.key }), id: \.key) { date, total in
//                            PointMark(
//                                x: .value("date", date),
//                                y: .value("total", total)
//                            )
//                            .annotation(position: .top, alignment: .center, spacing: 10) {
//                                Text("\(total, specifier: "%.1f")")
//                                    .bold()
//                                    .foregroundStyle(Color.white)
//                            }
//                            .symbol() {}
//                        }
