//
//  DropDownView.swift
//  Fitculator
//
//  Created by 임재현 on 2/20/25.
//

import SwiftUI


struct DropMenu: Identifiable {
    var id = UUID()
    var title: String
    var type: ExerciseType
}

let cardioExercises = [
    DropMenu(title: "달리기", type: .cardio),
    DropMenu(title: "자전거", type: .cardio),
    DropMenu(title: "수영", type: .cardio),
    DropMenu(title: "줄넘기", type: .cardio),
    DropMenu(title: "등산", type: .cardio),
    DropMenu(title: "걷기", type: .cardio)
]

let strengthExercises = [
    DropMenu(title: "벤치프레스", type: .strength),
    DropMenu(title: "스쿼트", type: .strength),
    DropMenu(title: "데드리프트", type: .strength),
    DropMenu(title: "숄더프레스", type: .strength),
    DropMenu(title: "턱걸이", type: .strength),
    DropMenu(title: "푸시업", type: .strength)
]

enum ExerciseType: String {
    case cardio = "유산소"
    case strength = "근력"
}


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
    
    var exerciseList: [DropMenu] {
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
                    selectedItem = item.title
                    isExpanded = false
                }) {
                    HStack {
                        Text(item.title)
                            .foregroundStyle(.white)
                        Spacer()
                    }
                    .frame(height: 44)
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal)
                    .background(
                        selectedItem == item.title
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
