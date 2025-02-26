//
//  RecordDetailView.swift
//  Fitculator
//
//  Created by MadCow on 2025/2/25.
//

import SwiftUI
import Charts

struct RecordDetailView: View {
    let record: TrainingRecord
    
    @State var showEditSheet: Bool = false
    @State var trainingNote: String = ""
    @State var textFieldHeight: CGFloat = 20
    @State var editMode: Bool = false
    
    var body: some View {
        GeometryReader { geo in
            NavigationStack {
                BackgroundView {
                    VStack(spacing: 50) {
                        VStack(spacing: 100) {
                            HStack {
                                VStack(alignment: .leading, spacing: 5) {
//                                    Text(record.exercise_name)
                                    Text(record.trainingName)
                                        .foregroundStyle(Color.white)
                                        .font(.title)
                                        .bold()
                                    
                                    Text(record.end_at.dateToString(includeDay: .time2))
                                        .foregroundStyle(Color(UIColor.lightGray))
                                        .font(.headline)
                                }
                                
                                Spacer()
                            }
                            
                            HStack {
                                Spacer()
                                
                                VStack(alignment: .trailing, spacing: 20) {
                                    VStack(alignment: .trailing, spacing: 20) {
                                        HStack(spacing: 20) {
//                                            Text(record.exercise_name)
                                            Text(record.trainingName)
                                                .foregroundStyle(Color.white)
                                                .font(.headline)
                                                .bold()
                                                .padding(.top, 10)
                                            
//                                            Text("\(record.earned_point, specifier: "%.1f") pt")
                                            Text("\(record.gained_point, specifier: "%.1f") pt")
                                                .foregroundStyle(Color.white)
                                                .font(.title)
                                                .bold()
                                        }
                                    }
                                    
                                    HStack(spacing: 30) {
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("시간")
                                                .foregroundStyle(Color(UIColor.lightGray))
                                                .font(.headline)
                                                .bold()
                                            
                                            HStack {
                                                HStack(spacing: 0) {
                                                    Text("\(record.duration)")
                                                        .foregroundStyle(Color.white)
                                                        .font(.title)
                                                        .bold()
                                                    
                                                    Text("min")
                                                        .foregroundStyle(Color(UIColor.lightGray))
                                                        .font(.headline)
                                                        .bold()
                                                        .padding(.top, 10)
                                                }
                                            }
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 5) {
                                            Text("평균 심박수")
                                                .foregroundStyle(Color(UIColor.lightGray))
                                                .font(.headline)
                                                .bold()
                                            
                                            HStack {
                                                HStack(spacing: 0) {
                                                    Text("\(record.avg_bpm)")
                                                        .foregroundStyle(Color.white)
                                                        .font(.title)
                                                        .bold()
                                                    
                                                    Text("bpm")
                                                        .foregroundStyle(Color(UIColor.lightGray))
                                                        .font(.headline)
                                                        .bold()
                                                        .padding(.top, 10)
                                                }
                                            }
                                        }
                                    }
                                    
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("운동 강도")
                                                .foregroundStyle(Color(UIColor.lightGray))
                                                .font(.headline)
                                                .bold()
                                            
                                            Text("\(record.training_intensity.rawValue)")
                                                .foregroundStyle(
                                                    record.training_intensity == .verLow ? Color.green : record.training_intensity == .low ? Color.blue : record.training_intensity == .normal ? Color.green : record.training_intensity == .high ? Color.red : Color.black
                                                )
                                                .font(.largeTitle)
                                                .bold()
                                        }
                                    }
                                }
                            }
                        }
                        .padding()
                        
                        VStack {
                            
                        }
                        .padding(.top, 20)
                        .frame(width: geo.size.width - 30, height: geo.size.height / 3)
                        .overlay {
                            RoundedRectangle(cornerRadius: 10)
                                .fill(Color.textFieldBackgrounColor)
                                .overlay(alignment: .top) {
                                    VStack {
                                        HStack {
                                            Text("운동 노트")
                                                .foregroundStyle(Color.white)
                                                .font(.title3)
                                                .bold()
                                            
                                            Spacer()
                                        }
                                        
                                        Rectangle()
                                            .fill(Color(UIColor.lightGray))
                                            .frame(height: 1)
                                        
                                        ZStack(alignment: .topLeading) {
                                            RoundedRectangle(cornerRadius: 8)
                                                .fill(Color.textFieldBackgrounColor)
                                                .frame(height: textFieldHeight)

                                            TextEditor(text: $trainingNote)
                                                .scrollContentBackground(.hidden)
                                                .background(Color.textFieldBackgrounColor)
                                                .frame(minHeight: textFieldHeight, maxHeight: geo.size.height / 6)
                                                .padding(.vertical, 8)
                                                .foregroundStyle(Color.white)
                                                .bold()
                                                .background(Color.clear)
                                                .onChange(of: trainingNote) {
                                                    updateHeight()
                                                }

                                            RoundedRectangle(cornerRadius: 8)
                                                .stroke(editMode ? Color(UIColor.lightGray) : Color.clear, lineWidth: 1)
                                                .frame(height: textFieldHeight)
                                        }
                                        .animation(.easeInOut, value: textFieldHeight)
                                    }
                                    .padding()
                                }
                        }
                        
                        Spacer()
                    }
                }
                .toolbar {
                    if editMode {
                        ToolbarItem(placement: .topBarLeading) {
                            Button {
                                editMode = false
                                // TODO: 만약 수정사항 있으면 원래 상태로 돌려야함
                            } label : {
                                Text("취소")
                                    .foregroundStyle(Color.white)
                            }
                        }
                        
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                editMode = false
                                // TODO: 운동 수정 API 실행
                            } label: {
                                Text("저장")
                                    .foregroundStyle(Color.white)
                            }
                            .tint(Color.white)
                        }
                    } else {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                showEditSheet = true
                            } label: {
                                Image(systemName: "ellipsis")
                            }
                            .tint(Color.white)
                        }
                    }
                }
                .confirmationDialog("TEST", isPresented: $showEditSheet, titleVisibility: .hidden) {
                    Button {
                        self.editMode = true
                    } label: {
                        Text("수정")
                    }
                    Button(role: .destructive) {
                        // TODO: 운동 기록 삭제 API 실행
                    } label: {
                        Text("삭제")
                    }
                    Button(role: .cancel) {} label: {
                        Text("취소")
                    }
                }
                .overlay {
                    Chart {
                        SectorMark(
                            angle: .value("Pct", record.gained_point),
                            innerRadius: .ratio(0.5),
                            angularInset: 1
                        )
                        .foregroundStyle(Color.green)
                        .annotation(position: .overlay, alignment: .center) {
                            Text("\(record.gained_point, specifier: "%.1f")%")
                                .font(.headline)
                                .bold()
                                .padding(.top, 20)
                                .foregroundStyle(Color.white)
                        }
                        
                        SectorMark(
                            angle: .value("Pct", 100 - record.gained_point),
                            innerRadius: .ratio(0.5),
                            angularInset: 1
                        )
                        .foregroundStyle(Color.gray.opacity(0.3))
                    }
                    .frame(width: geo.size.width / 1.4, height: geo.size.height / 2)
                    .offset(x: -180, y: -100)
                }
                .onAppear {
                    self.trainingNote = record.training_detail ?? ""
                }
            }
        }
    }
    
    private func updateHeight() {
        let lineHeight: CGFloat = 20
        let lineCount = CGFloat(trainingNote.split(separator: "\n").count)
        textFieldHeight = min(20 + lineHeight * lineCount, 200)
    }
}

//#Preview {
//    RecordDetailView(
//        record: Record(
//            user_id: 1,
//            exercise_name: "테니스",
//            avg_bpm: 100,
//            max_bpm: 100,
//            duration: 100,
//            end_at: Date().dateToString(includeDay: .time2),
//            exercise_intensity: .verLow,
//            earned_point: 20,
//            exercise_note: "아 재밌었다."
//        )
//    )
//}
