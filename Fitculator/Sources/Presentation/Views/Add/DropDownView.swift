//
//  DropDownView.swift
//  Fitculator
//
//  Created by 임재현 on 2/20/25.
//

import SwiftUI

struct DropdownView: View {
    @State var show: Bool = false
    @State var name: String = "Item1"
    
    var body: some View {
        VStack {
            ZStack {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                    ScrollView {
                        VStack(spacing:17){
                            ForEach(drop) { item in
                                Button {
                                    withAnimation {
                                        name = item.title
                                        show.toggle()
                                    }
                                } label: {
                                    Text(item.title).foregroundStyle(.white.opacity(0.6))
                                        .bold()
                                    Spacer()
                                }
                            }
                        }
                        .frame(maxWidth: .infinity,alignment: .leading)
                        .padding(.vertical,15)
                        
                    }
                }
                .frame(height: show ? 200 : 50)
                .offset(y: show ? 0 : -135)
                .foregroundStyle(.gray)
                ZStack {
                    RoundedRectangle(cornerRadius: 10).frame(height: 60)
                        .foregroundStyle(.gray)
                    HStack {
                        Text(name).font(.title2)
                        Spacer()
                        
                        Image(systemName: "chevron.right")
                    }
                    .bold()
                    .padding(.horizontal)
                    .foregroundStyle(.white)
                }
                .offset(y: -133)
                .onTapGesture {
                    withAnimation {
                        show.toggle()
                    }
                }
            }
        }
        .padding()
        .frame(height: 200)
        .offset(y:40)
    }
}

struct DropMenu: Identifiable {
    var id = UUID()
    var title: String
}

let drop = [
    DropMenu(title: "Item1"),
    DropMenu(title: "Item2"),
    DropMenu(title: "Item3"),
    DropMenu(title: "Item4"),
    DropMenu(title: "Item5"),
    DropMenu(title: "Item6")
    
]
