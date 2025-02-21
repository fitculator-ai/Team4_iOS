import SwiftUI

enum Field: Hashable {
    case exerciseTime
    case minHeartRate
    case maxHeartRate
    case memo
}

struct AddView: View {
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var offset: CGFloat = 0
    @FocusState private var focusedField: Field?
    @State private var currentField: Field?
    @State private var selectedExerciseType: String? = nil
    @State private var showDropdown: Bool = false
    
    var body: some View {
        ZStack(alignment: .top) {
            Color.clear
                .ignoresSafeArea()
                .contentShape(Rectangle())
                .onTapGesture {
                    hideKeyboard()
                }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 20) {
                    DateTimeSection(
                        selectedDate: $selectedDate,
                        showDatePicker: $showDatePicker
                    )
                    .padding(.top, 100)
                    
                    TimeInputSection()
                        .padding(.top, 16)
                    
                    ExerciseTypeSection(
                        selectedExerciseType: $selectedExerciseType,
                        showDropdown: $showDropdown
                    )
                    .zIndex(1)
                    
                    ExerciseTimeSection(currentField: $currentField)
                        .onChange(of: currentField) { field in
                            focusedField = field
                        }
                        .padding(.top, showDropdown ? -4: 8)
                        .onChange(of: focusedField) { field in
                            currentField = field
                        }
                        .zIndex(0)
                        .padding(.top, -25)
                    
                    HeartRateSection(currentField: $currentField)
                        .zIndex(0)
                    
                    MemoSection(currentField: $currentField)
                    
                    ButtonSection()
                        .padding(.bottom, 30)
                }
                .frame(maxWidth: .infinity)
                .background(Color.fitculatorBackgroundColor)
            }
            .background(Color.fitculatorBackgroundColor)
            .offset(y: -offset)
        }
        .onTapGesture {
            hideKeyboard()
        }
        .onAppear {
            setupKeyboardNotifications()
        }
        .onDisappear {
            removeKeyboardNotifications()
        }
    }
    
    private func hideKeyboard() {
        focusedField = nil
        withAnimation {
            offset = 0
        }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillShowNotification,
            object: nil,
            queue: .main
        ) { notification in
            guard let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect,
                  let duration = notification.userInfo?[UIResponder.keyboardAnimationDurationUserInfoKey] as? Double else { return }
            
            let keyboardHeight = keyboardFrame.height
            
            if focusedField == .memo {
                withAnimation(.easeOut(duration: duration)) {
                    // ScrollView를 키보드 높이만큼 위로 올립니다
                    self.offset = keyboardHeight + 600  // 100은 추가 여백입니다
                }
            } else {
                withAnimation(.easeOut(duration: duration)) {
                    self.offset = 0
                }
            }
        }
        
        NotificationCenter.default.addObserver(
            forName: UIResponder.keyboardWillHideNotification,
            object: nil,
            queue: .main
        ) { _ in
            withAnimation {
                offset = 0
            }
        }
    }
    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
}

struct DateTimeSection: View {
    @Binding var selectedDate: Date
    @Binding var showDatePicker: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("날짜 및 시간")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                Spacer()
            }
            
            Button {
                showDatePicker.toggle()
            } label: {
                HStack {
                    Text(selectedDate, style: .date)
                        .padding(.leading)
                        .foregroundStyle(.white)
                    
                    Spacer()
                    
                    Image(systemName: "calendar")
                        .foregroundColor(.gray)
                        .frame(width: 35, height: 35)
                        .padding(.trailing, 10)
                }
                .frame(maxWidth: .infinity)
                .frame(height: 40)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.gray, lineWidth: 2)
                )
            }
        }
        .background(Color.fitculatorBackgroundColor)
        .padding(.horizontal, 20)
        .sheet(isPresented: $showDatePicker) {
            DatePickerSheet(selectedDate: $selectedDate, showDatePicker: $showDatePicker)
        }
    }
}

struct DatePickerSheet: View {
    @Binding var selectedDate: Date
    @Binding var showDatePicker: Bool
    
    var body: some View {
        VStack(spacing: 0) {
            HStack {
                Spacer()
                Button("확인") {
                    showDatePicker = false
                }
                .foregroundStyle(.white)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
            }
            
            HStack {
                Spacer()
                DatePicker("", selection: $selectedDate, displayedComponents: [.date])
                    .datePickerStyle(.wheel)
                    .environment(\.colorScheme, .dark)
                    .labelsHidden()
                Spacer()
            }
            .frame(maxWidth: .infinity)
        }
        .presentationDetents([.height(350)])
        .presentationBackground(Color.fitculatorBackgroundColor)
    }
}

struct TimeInputSection: View {
    @State private var hourText: String = ""
    @State private var minuteText: String = ""
    @State private var isAM: Bool = true
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("운동 시작 시간")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                Spacer()
            }
            
            HStack(spacing: 15) {
                TimeField(text: $hourText, unit: "시", width: 80)
                
                Text(":")
                    .foregroundColor(.gray)
                    .font(.system(size: 20, weight: .bold))
                
                TimeField(text: $minuteText, unit: "분", width: 80)
                
                Spacer()
                
                AMPMToggle(isAM: $isAM)
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 10)
        }
        .background(Color.fitculatorBackgroundColor)
        .padding(.horizontal, 20)
    }
}

struct TimeField: View {
    @Binding var text: String
    let unit: String
    let width: CGFloat
    
    var body: some View {
        HStack {
            TextField("", text: $text)
                .keyboardType(.numberPad)
                .foregroundStyle(.white)
                .padding(.leading, 10)
            
            if !text.isEmpty {
                Text(unit)
                    .foregroundStyle(.gray)
                    .padding(.trailing, 10)
            }
        }
        .frame(width: width, height: 40)
        .background(Color.gray.opacity(0.3))
        .cornerRadius(4)
    }
}

struct AMPMToggle: View {
    @Binding var isAM: Bool
    
    var body: some View {
        HStack(spacing: 15) {
            Text("오전")
                .frame(width: 45, height: 35)
                .foregroundColor(isAM ? .blue : .gray)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
                .onTapGesture {
                    isAM = true
                }
            
            Text("오후")
                .frame(width: 45, height: 35)
                .foregroundColor(!isAM ? .blue : .gray)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
                .onTapGesture {
                    isAM = false
                }
        }
    }
}
struct ExerciseTypeSection: View {
    @Binding var selectedExerciseType: String?
    @Binding var showDropdown: Bool
    
    var body: some View {
        ZStack(alignment: .top) {
            VStack(spacing: 0) {
                HStack {
                    Text("운동종류")
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                    Spacer()
                }
                
                HStack {
                    Button {
                        withAnimation(.spring()) {
                            selectedExerciseType = "유산소"
                            showDropdown = true
                        }
                    } label: {
                        Text("유산소")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundStyle(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(.gray, lineWidth: 2)
                            )
                    }
                    
                    Button {
                        withAnimation(.spring()) {
                            selectedExerciseType = "근력"
                            showDropdown = true
                        }
                    } label: {
                        Text("근력")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundStyle(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(.gray, lineWidth: 2)
                            )
                    }
                }
                .padding(.top, 8)
            }
            .background(Color.fitculatorBackgroundColor)
            .padding(.horizontal, 20)
            .padding(.top, 8)
            
            if showDropdown {
                DropdownView()
                    .padding(.horizontal, 20)
                    .offset(y: 120)
                    .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.fitculatorBackgroundColor)
    }
}

struct ExerciseTypeButton: View {
    let title: String
    @Binding var selectedType: String?
    @Binding var showDropdown: Bool
    
    var body: some View {
        Button {
            withAnimation(.spring()) {
                selectedType = title
                showDropdown = true
            }
        } label: {
            Text(title)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .foregroundStyle(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.gray, lineWidth: 2)
                )
        }
    }
}

struct ExerciseTimeSection: View {
    @State private var exerciseTime: String = ""
    @Binding var currentField: Field?
    @FocusState private var focused: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("운동시간 (분)")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                Spacer()
            }
            
            TextField("", text: $exerciseTime)
                .placeholder(when: exerciseTime.isEmpty) {
                    Text("운동시간")
                        .foregroundStyle(Color.gray)
                }
                .keyboardType(.numberPad)
                .foregroundColor(.white)
                .padding(.leading, 10)
                .frame(height: 50)
                .background(Color.fitculatorBackgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 4)
                        .stroke(.gray, lineWidth: 2)
                )
                .focused($focused)
                .onChange(of: focused) { isFocused in
                    currentField = isFocused ? .exerciseTime : nil
                }
                .onChange(of: currentField) { field in
                    focused = field == .exerciseTime
                }
        }
        .padding(.horizontal, 20)
        .padding(.top, 8)
    }
}

struct HeartRateSection: View {
    @State private var minHeartRate: String = ""
    @State private var maxHeartRate: String = ""
    @Binding var currentField: Field?
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack {
            HStack {
                Text("심박수")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                Spacer()
            }
            
            HStack(spacing: 20) {
                HeartRateField(
                    text: $minHeartRate,
                    placeholder: "최저 심박수",
                    currentField: $currentField,
                    field: .minHeartRate
                )
                
                HeartRateField(
                    text: $maxHeartRate,
                    placeholder: "최대 심박수",
                    currentField: $currentField,
                    field: .maxHeartRate
                )
            }
        }
        .padding(.horizontal, 20)
    }
}
struct HeartRateField: View {
    @Binding var text: String
    let placeholder: String
    @Binding var currentField: Field?
    let field: Field
    @FocusState private var focused: Bool
    
    var body: some View {
        HStack {
            TextField("", text: $text)
                .keyboardType(.numberPad)
                .focused($focused)
                .onChange(of: focused) { isFocused in
                    currentField = isFocused ? field : nil
                }
                .onChange(of: currentField) { newField in
                    focused = newField == field
                }
                .placeholder(when: text.isEmpty) {
                    Text(placeholder)
                        .foregroundStyle(Color.gray)
                }
                .foregroundStyle(.white)
                .padding(.leading, 10)
            
            if !text.isEmpty {
                Text("bpm")
                    .foregroundStyle(.gray)
                    .padding(.trailing, 10)
            }
        }
        .frame(height: 50)
        .background(Color.fitculatorBackgroundColor)
        .overlay(
            RoundedRectangle(cornerRadius: 4)
                .stroke(.gray, lineWidth: 2)
        )
    }
}

struct MemoSection: View {
    @State private var memoText: String = ""
    @Binding var currentField: Field?
    @FocusState private var focused: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("메모")
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                Spacer()
            }
            
            CustomTextView(text: $memoText, onFocus: { isFocused in
                currentField = isFocused ? .memo : nil
            })
                .frame(height: 200)
                .padding()
                .background(Color.gray.opacity(0.2))
                .cornerRadius(8)
        }
        .padding(.horizontal, 20)
    }
}

struct ButtonSection: View {
    var body: some View {
        HStack {
            Button {
                print("git test2")
            } label: {
                Text("메모")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(Color.gray)
                    .clipShape(.capsule)
            }
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}

