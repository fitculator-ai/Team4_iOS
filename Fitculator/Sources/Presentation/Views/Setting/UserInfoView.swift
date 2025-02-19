import SwiftUI

struct UserInfoView: View {
    @ObservedObject var viewModel: SettingViewModel
    
    var dateRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
        let max = Calendar.current.date(byAdding: .day, value: 0, to: Date())!
        return min...max
    }
    
    var body: some View {
        Section {
            HStack {
                Text("이름")
                Spacer()
                Text(viewModel.user.name)
                    .foregroundStyle(.gray)
            }
            .listRowBackground(Color.brightBackgroundColor)
            
            HStack {
                Text("닉네임")
                Spacer()
                if viewModel.isEditing {
                    TextField("닉네임 입력", text: $viewModel.tempUser.nickName)
                        .textFieldStyle(DefaultTextFieldStyle())
                        .frame(width: 150)
                        .multilineTextAlignment(.trailing)
                } else {
                    Text(viewModel.user.nickName)
                        .foregroundStyle(.gray)
                }
            }
            .listRowBackground(Color.brightBackgroundColor)
            
            HStack {
                Text("성별")
                Spacer()
                Text(viewModel.user.gender.rawValue)
                    .foregroundStyle(.gray)
            }
            .listRowBackground(Color.brightBackgroundColor)
            
            HStack {
                Text("키(cm)")
                Spacer()
                if viewModel.isEditing {
                    Picker("", selection: $viewModel.tempUser.height) {
                        ForEach(130...250, id: \.self) { height in
                            Text("\(height) cm").tag(height)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                } else {
                    Text("\(viewModel.user.height)cm")
                        .foregroundStyle(.gray)
                }
            }
            .listRowBackground(Color.brightBackgroundColor)
            
            HStack {
                Text("생년월일")
                Spacer()
                if viewModel.isEditing {
                    DatePicker("", selection: $viewModel.tempUser.birthDate, in: dateRange, displayedComponents: .date)
                } else {
                    Text(viewModel.formatDate(viewModel.user.birthDate))
                        .foregroundStyle(.gray)
                }
            }
            .listRowBackground(Color.brightBackgroundColor)
        }
    }
}
