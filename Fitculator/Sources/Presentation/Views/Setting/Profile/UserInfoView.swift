import SwiftUI

struct UserInfoView: View {
    let userAccount: UserAccount
    @Binding var userDetails: UserDetails
    @Binding var isEditing: Bool
    @State private var tempBirthDate: Date = Date()
    
    var dateRange: ClosedRange<Date> {
        let min = Calendar.current.date(byAdding: .year, value: -100, to: Date())!
        let max = Calendar.current.date(byAdding: .day, value: 0, to: Date())!
        return min...max
    }
    
    var body: some View {
        Section {
            HStack {
                Text("name".localized)
                Spacer()
                Text("\(userAccount.name)")
                    .foregroundStyle(.gray)
            }
            .listRowBackground(Color.brightBackgroundColor)
            
            HStack {
                Text("nickname".localized)
                Spacer()
                if isEditing {
                    TextField("nickname_placeholder".localized, text: $userDetails.userNickname)
                        .textFieldStyle(DefaultTextFieldStyle())
                        .frame(width: 150)
                        .multilineTextAlignment(.trailing)
                        .onChange(of: userDetails.userNickname) {
                            userDetails.userNickname = filterNickname(userDetails.userNickname)
                        }
                } else {
                    Text(userDetails.userNickname)
                        .foregroundStyle(.gray)
                }
            }
            .listRowBackground(Color.brightBackgroundColor)
            
            HStack {
                Text("gender".localized)
                Spacer()
                Text(userDetails.gender)
                    .foregroundStyle(.gray)
                
            }
            .listRowBackground(Color.brightBackgroundColor)
            
            HStack {
                Text("height".localized)
                Spacer()
                if isEditing {
                    Picker("", selection: $userDetails.height) {
                        ForEach(130...250, id: \.self) { height in
                            Text("\(height) cm").tag(height)
                        }
                    }
                    .pickerStyle(DefaultPickerStyle())
                } else {
                    Text("\(userDetails.height)cm")
                        .foregroundStyle(.gray)
                }
            }
            .listRowBackground(Color.brightBackgroundColor)
            
            HStack {
                Text("birthdate".localized)
                Spacer()
                if isEditing {
                    DatePicker("", selection: $tempBirthDate, in: dateRange, displayedComponents: .date)
                        .onAppear {
                            if let birthDate = isoStringToDate(userDetails.birth) {
                                tempBirthDate = birthDate
                            }
                        }
                        .onChange(of: tempBirthDate) {
                            userDetails.birth = dateToISOString(tempBirthDate) ?? ""
                            
                        }
                } else {
                    Text(formatDate(isoStringToDate(userDetails.birth) ?? Date()))
                        .foregroundStyle(.gray)
                }
            }
            .listRowBackground(Color.brightBackgroundColor)
        }
    }
}

func filterNickname(_ input: String) -> String {
    let filtered = input.filter { $0.isLetter || $0.isNumber }
    return String(filtered.prefix(10))
}

func formatDate(_ date: Date) -> String {
    let formatter = DateFormatter()
    formatter.dateFormat = "yyyy.MM.dd"
    return formatter.string(from: date)
}

func isoStringToDate(_ isoString: String?) -> Date? {
    guard let isoString = isoString, !isoString.isEmpty else { return nil }
    
    let isoWithZ = isoString + "Z"
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    let date = formatter.date(from: isoWithZ)
    return date
}

func dateToISOString(_ date: Date?) -> String? {
    guard let date = date else { return nil }
    let formatter = ISO8601DateFormatter()
    formatter.formatOptions = [.withInternetDateTime]
    return formatter.string(from: date)
}
