//
//  DropDownView.swift
//  Fitculator
//
//  Created by 임재현 on 2/20/25.
//

import SwiftUI


struct ExerciseData: Identifiable {
    var id: Int
    var name: String
}

enum ExerciseType: String {
    case cardio = "유산소"
    case strength = "근력"
}

// API 응답 데이터에 맞게 업데이트된 데이터
let cardioExercises = [
    ExerciseData(id: 1, name: "달리기"),
    ExerciseData(id: 2, name: "사이클"),
    ExerciseData(id: 3, name: "수영"),
    ExerciseData(id: 4, name: "줄넘기"),
    ExerciseData(id: 5, name: "등산"),
    ExerciseData(id: 6, name: "조깅"),
    ExerciseData(id: 7, name: "걷기"),
    ExerciseData(id: 8, name: "로잉머신"),
    ExerciseData(id: 9, name: "에어로빅"),
    ExerciseData(id: 10, name: "스피닝")
]

let strengthExercises = [
    ExerciseData(id: 11, name: "스쿼트"),
    ExerciseData(id: 12, name: "데드리프트"),
    ExerciseData(id: 13, name: "벤치프레스"),
    ExerciseData(id: 14, name: "풀업"),
    ExerciseData(id: 15, name: "랫풀다운"),
    ExerciseData(id: 16, name: "바벨 로우"),
    ExerciseData(id: 17, name: "숄더 프레스"),
    ExerciseData(id: 18, name: "런지"),
    ExerciseData(id: 19, name: "케틀벨 스윙"),
    ExerciseData(id: 20, name: "레그 프레스")
]

struct DropdownHeader: View {
    @Binding var selectedItem: String
    @Binding var isExpanded: Bool
    
    var body: some View {
        Button(action: {
            isExpanded.toggle()
        }) {
            HStack {
                Text(selectedItem)
                    .foregroundStyle(.white)
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .foregroundStyle(.gray)
            }
            .frame(height: 44)
            .padding(.horizontal)
        }
    }
}

struct DropdownContent: View {
    let selectedExerciseType: String?
    @Binding var selectedItem: String
    @Binding var isExpanded: Bool
    var onItemSelected: ((Int) -> Void)? = nil
    
    var exerciseList: [ExerciseData] {
        switch selectedExerciseType {
        case "유산소":
            return cardioExercises
        case "근력":
            return strengthExercises
        default:
            return []
        }
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ForEach(exerciseList) { item in
                Button(action: {
                    selectedItem = item.name
                    isExpanded = false
                    onItemSelected?(item.id) 
                }) {
                    HStack {
                        Text(item.name)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .background(
                        selectedItem == item.name
                        ? Color.gray.opacity(0.3)
                        : Color.clear
                    )
                }
            }
        }
        .padding(.vertical, 8)
        .background(Color.fitculatorBackgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(Color.gray, lineWidth: 1)
        )
    }
}
