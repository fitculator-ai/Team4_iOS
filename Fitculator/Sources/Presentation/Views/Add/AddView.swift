import SwiftUI

enum Field: Hashable {
    case exerciseTime
    case minHeartRate
    case maxHeartRate
    case memo
}

struct AddView: View {
    @StateObject var viewModel: AddViewModel = AddViewModel(addUseCase: ExerciseListUseCase(repository: ExerciseListRepository(networkService: NetworkService(session: .shared))))
    @Environment(\.presentationMode) var presentationMode
    @State private var selectedDate = Date()
    @State private var showDatePicker = false
    @State private var keyboardHeight: CGFloat = 0
    @State private var offset: CGFloat = 0
    @FocusState private var focusedField: Field?
    @State private var currentField: Field?
    @State private var selectedExerciseType: String? = nil
    @State private var showDropdown: Bool = false
    
    var body: some View {
        GeometryReader { geometry in
            
            VStack(spacing: 0) {
                HStack {
                    Button {
                        presentationMode.wrappedValue.dismiss()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.white)
                            .padding()
                    }
                    Spacer()
                    Text("add".localized)
                        .foregroundColor(.white)
                        .font(.headline)
                    Spacer()
                    
                    Rectangle()
                        .fill(Color.clear)
                        .frame(width: 44, height: 44)
                }

                .frame(height: 44)
                .padding(.top, UIApplication.shared.windows.first?.safeAreaInsets.top ?? 0)
                .background(Color.fitculatorBackgroundColor)
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
                                selectedDate: $viewModel.selectedDate,
                                showDatePicker: $showDatePicker
                            )
                            .padding(.top, 20)
                            
                            TimeInputSection(
                                hourText: $viewModel.hourText,
                                minuteText: $viewModel.minuteText,
                                isAM: $viewModel.isAM,
                                onTimeChange: {
                                    updateStartTime()
                                }
                            )
                            .padding(.top, 16)
                            
                            ExerciseTypeSection(
                                selectedExerciseType: $selectedExerciseType,
                                showDropdown: $showDropdown,
                                onExerciseSelected: { exerciseId in
                                    viewModel.exerciseId = exerciseId
                                }
                            )
                            .zIndex(1)
                            
                            ExerciseTimeSection(
                                exerciseTime: Binding(
                                    get: { viewModel.exerciseTime == 0 ? "" : "\(viewModel.exerciseTime)" },
                                    set: { viewModel.exerciseTime = Int($0) ?? 0 }
                                ),
                                currentField: $currentField
                            )
                            .onChange(of: currentField) { field in
                                focusedField = field
                            }
                            .padding(.top, showDropdown ? -4: 8)
                            .onChange(of: focusedField) { field in
                                currentField = field
                            }
                            .zIndex(0)
                            .padding(.top, -25)
                            
                            HeartRateSection(
                                minHeartRate: Binding(
                                    get: { viewModel.minHeartRate == 0 ? "" : "\(viewModel.minHeartRate)" },
                                    set: { viewModel.minHeartRate = Int($0) ?? 0 }
                                ),
                                maxHeartRate: Binding(
                                    get: { viewModel.maxHeartRate == 0 ? "" : "\(viewModel.maxHeartRate)" },
                                    set: { viewModel.maxHeartRate = Int($0) ?? 0 }
                                ),
                                currentField: $currentField
                            )
                                .zIndex(0)
                            
                            MemoSection(
                                memoText: $viewModel.memo,
                                currentField: $currentField
                            )
                            
                            ButtonSection(viewModel: viewModel)
                                .padding(.bottom, 30)
                        }
                        .frame(maxWidth: .infinity)
                        .background(Color.fitculatorBackgroundColor)
                    }
                    .background(Color.fitculatorBackgroundColor)
               
                }
            }
            .offset(y: offset)
            .setupKeyboardHandling(geometry: geometry, offset: $offset)
            .ignoresSafeArea(.all, edges: .top)
            .onTapGesture {
                hideKeyboard()
            }

            .onAppear {
                viewModel.fetchExerciesList()
            }
            .onDisappear {
            }
        }

    }
    
    private func hideKeyboard() {
        focusedField = nil
        withAnimation {
            offset = 0
        }
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
    

    private func removeKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func updateStartTime() {
        // 시간과 분을 Date로 변환
        let hour = Int(viewModel.hourText) ?? 0
        let minute = Int(viewModel.minuteText) ?? 0
        
        let calendar = Calendar.current
        var components = calendar.dateComponents([.year, .month, .day], from: viewModel.selectedDate)
        
        // AM/PM 적용
        components.hour = viewModel.isAM ? hour : hour + 12
        components.minute = minute
        
        if let date = calendar.date(from: components) {
            viewModel.startTime = date
        }
    }
}

struct DateTimeSection: View {
    @Binding var selectedDate: Date
    @Binding var showDatePicker: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("date_time".localized)
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
    @Binding var hourText: String
    @Binding var minuteText: String
    @Binding var isAM: Bool
    var onTimeChange: () -> Void
    
    var body: some View {
        VStack(spacing: 10) {
            HStack {
                Text("workout_start_time".localized)
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
            Text("am".localized)
                .frame(width: 45, height: 35)
                .foregroundColor(isAM ? .blue : .gray)
                .background(Color.gray.opacity(0.2))
                .cornerRadius(4)
                .onTapGesture {
                    isAM = true
                }
            
            Text("pm".localized)
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
    @State private var selectedItem: String = "운동 선택"
    var onExerciseSelected: ((Int) -> Void)? = nil
    
    var body: some View {
        ZStack(alignment: .top) {
            // 메인 컨텐츠
            VStack(spacing: 0) {
                HStack {
                    Text("workout_category".localized)
                        .font(.system(size: 16))
                        .foregroundStyle(.white)
                    Spacer()
                }
                
                // 유산소/근력 버튼
                HStack {
                    Button {
                        withAnimation(.spring()) {
                            selectedExerciseType = "cardio".localized
                            showDropdown = true
                            onExerciseSelected?(1) // 유산소는 ID 1로 가정
                        }
                    } label: {
                        Text("cardio".localized)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundStyle(selectedExerciseType == "cardio".localized ? .blue : .white)
                            .background(selectedExerciseType == "cardio".localized ? Color.blue.opacity(0.2) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(selectedExerciseType == "cardio".localized ? .blue : .gray, lineWidth: 2)
                            )
                    }
                    
                    Button {
                        withAnimation(.spring()) {
                            selectedExerciseType = "strength".localized
                            showDropdown = true
                            onExerciseSelected?(2) // 근력은 ID 2로 가정
                        }
                    } label: {
                        Text("strength".localized)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundStyle(selectedExerciseType == "strength".localized ? .blue : .white)
                            .background(selectedExerciseType == "strength".localized ? Color.blue.opacity(0.2) : Color.clear)
                            .overlay(
                                RoundedRectangle(cornerRadius: 4)
                                    .stroke(selectedExerciseType == "strength".localized ? .blue : .gray, lineWidth: 2)
                            )
                    }
                }
                .padding(.top, 8)
                
                // 드롭다운 헤더
                if selectedExerciseType != nil {
                    DropdownHeader(
                        selectedItem: $selectedItem,
                        isExpanded: $showDropdown
                    )
                    .background(Color.fitculatorBackgroundColor)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(Color.gray, lineWidth: 1)
                    )
                    .cornerRadius(10)
                    .padding(.top, 8)
                }
            }
            .padding(.horizontal, 20)
            
            // 드롭다운 컨텐츠 (오버레이)
            if showDropdown {
                DropdownContent(
                    selectedExerciseType: selectedExerciseType,
                    selectedItem: $selectedItem,
                    isExpanded: $showDropdown,
                    onItemSelected: { itemId in
                        onExerciseSelected?(itemId)
                    }
                )
                .background(Color.fitculatorBackgroundColor)
                .cornerRadius(10)
                .shadow(radius: 5)
                .offset(y: 85)
                .zIndex(1)
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
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
    @Binding var exerciseTime: String
    @Binding var currentField: Field?
    @FocusState private var focused: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("workout_duration".localized)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                Spacer()
            }
            
            TextField("", text: $exerciseTime)
                .placeholder(when: exerciseTime.isEmpty) {
                    Text("workout_time".localized)
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
    @Binding var minHeartRate: String
    @Binding var maxHeartRate: String
    @Binding var currentField: Field?
    @FocusState private var focusedField: Field?
    
    var body: some View {
        VStack {
            HStack {
                Text("heart_rate".localized)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                Spacer()
            }
            
            HStack(spacing: 20) {
                HeartRateField(
                    text: $minHeartRate,
                    placeholder: "min_heart_rate".localized,
                    currentField: $currentField,
                    field: .minHeartRate
                )
                
                HeartRateField(
                    text: $maxHeartRate,
                    placeholder: "max_heart_rate".localized,
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
    @Binding var memoText: String
    @Binding var currentField: Field?
    @FocusState private var focused: Bool
    
    var body: some View {
        VStack {
            HStack {
                Text("memo".localized)
                    .font(.system(size: 16))
                    .foregroundStyle(.white)
                Spacer()
            }
            
            CustomTextView(text: $memoText, onFocus: { isFocused in
                // 포커스 상태 변경 시 currentField 업데이트
                withAnimation {
                    currentField = isFocused ? .memo : nil
                }
                print("메모 포커스: \(isFocused), 현재 필드: \(String(describing: currentField))")
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
    @ObservedObject var viewModel: AddViewModel
    @Environment(\.presentationMode) var presentationMode
    var body: some View {
        HStack {
            Button {
                viewModel.submitExerciseRecord()
                presentationMode.wrappedValue.dismiss()
                
            } label: {
                Text("memo".localized)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .frame(height: 50)
                    .background(viewModel.isFormValid ? Color.blue : Color.gray)
                    .clipShape(.capsule)
            }
            .disabled(!viewModel.isFormValid)
        }
        .padding(.horizontal, 20)
        .padding(.bottom, 20)
    }
}


struct KeyboardHandlingModifier: ViewModifier {
    let geometry: GeometryProxy
    @Binding var offset: CGFloat
    
    func body(content: Content) -> some View {
        content.onAppear {
            setupKeyboardNotifications()
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            let textFieldPosition = geometry.size.height * 0.7
            let overlap = textFieldPosition + keyboardFrame.height - geometry.size.height
            
            if overlap > 0 {
                withAnimation(.easeOut(duration: 0.3)) {
                    offset = -overlap - 20
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation(.easeOut(duration: 0.3)) {
                offset = 0
            }
        }
    }
}
